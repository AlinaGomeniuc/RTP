defmodule Feeder do
  use GenServer

  def start_link(count) do
    GenServer.start_link(__MODULE__, count, name: __MODULE__)
  end

  def send_event(feeder_pid, event) do
    GenServer.cast(feeder_pid, {:send_event, event})
  end

  @impl true
  def init(count) do
    IO.inspect "Feeder starts #{count} workers"

    workers = 1..count |>
    Enum.map(fn id ->
      worker = "Worker #{id}"
      MySupervisor.start_child(worker)
      worker
    end)|> List.to_tuple

    id = 0

    {:ok, {workers, id}}
  end

  @impl true
  def handle_cast({:send_event, event}, feeder_state) do
    workers = elem(feeder_state, 0)
    id = generate_id(feeder_state)
    elem(workers, id-1) |> Forecast.process_event(event)

    {:noreply, {elem(feeder_state, 0), id}}
  end

  defp generate_id(state)do
    id = elem(state, 1)
    id = if id < tuple_size(elem(state, 0)) do id + 1  else  1 end
    id
  end
end
