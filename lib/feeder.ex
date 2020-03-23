defmodule Feeder do
  use GenServer

  def start_link(worker_count) do
    GenServer.start_link(__MODULE__, worker_count, name: __MODULE__)
  end

  def send_event(feeder_pid, event) do
    GenServer.cast(feeder_pid, {:send_event, event})
  end

  @impl true
  def init(worker_count) do
    IO.inspect "Feeder starts #{worker_count} workers"

    workers = 1..worker_count |>
    Enum.map(fn id ->
      worker = "Worker #{id}"
      MySupervisor.start_child(worker)
      worker
    end)|> List.to_tuple

    Process.send_after(self(), :check_events, 500)
    event_count = 0

    {:ok, {workers, worker_count, event_count}}
  end

  @impl true
  def handle_cast({:send_event, event}, feeder_state) do
    workers = elem(feeder_state, 0)
    worker_id = generate_worker_id(feeder_state)
    elem(workers, worker_id-1) |> Forecast.process_event(event)
    event_count = elem(feeder_state, 2) + 1
    total_workers = Registry.count(:workers_registry)

    IO.inspect event_count
    IO.inspect feeder_state
    IO.inspect "-----------------"
    {:noreply, {elem(feeder_state, 0), total_workers, event_count}}
  end

  @impl true
  def handle_info(:check_events, feeder_state) do
    workers = elem(feeder_state, 0)
    event_count = elem(feeder_state, 2)

    required_worker_nr = get_required_nr_workers(event_count)

    # workers =
    #   if required_worker_nr > total_workers do
    #     add_worker(workers, required_worker_nr, total_workers)
    #   end

    total_workers = Registry.count(:workers_registry)
      IO.inspect event_count
      IO.inspect feeder_state
      {:noreply, {workers, total_workers, 0}}
  end

  defp generate_worker_id(state)do
    worker_count = elem(state, 1)
    worker_count = if worker_count < tuple_size(elem(state, 0)) do worker_count + 1  else  1 end
    worker_count
  end

  defp get_required_nr_workers(event_counter) do
    cond do
      event_counter < 10 -> 1
      event_counter > 10 && event_counter <= 30 -> 2
      event_counter > 30 && event_counter <= 50 -> 4
      event_counter > 50 && event_counter <= 70 -> 6
      event_counter > 70 && event_counter <= 100 -> 8
      event_counter > 100 && event_counter <= 130 -> 11
      event_counter > 130 && event_counter <= 150 -> 14
      event_counter > 150 && event_counter <= 170 -> 16
      event_counter > 170 && event_counter <= 200 -> 18
      event_counter > 200 && event_counter <= 250 -> 23
      event_counter > 250 && event_counter <= 300 -> 27
      event_counter > 300 && event_counter <= 350 -> 33
      event_counter > 350 && event_counter <= 400 -> 37
      event_counter > 400 && event_counter <= 450 -> 43
      event_counter > 450 -> 60
      true -> 10
    end
  end

  defp add_worker(workers, required_worker_nr, workers_count) do
    list_workers = Tuple.to_list(workers)

   new_workers = workers_count+1 .. required_worker_nr |>
    Enum.map(fn id ->
      worker = "Worker #{id}"
      MySupervisor.start_child(worker)
      worker
    end)

    new_workers = Enum.reverse(new_workers)
    list_workers ++ new_workers |> List.to_tuple
  end
end
