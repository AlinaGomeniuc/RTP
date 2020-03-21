defmodule Root do
  use GenServer

  def start_link(count) do
    GenServer.start_link(__MODULE__, count, name: __MODULE__)
  end

  @impl true
  def init(count) do
    IO.inspect "Root starts #{count} workers"

    workers = 1..count |>
    Enum.map(fn id ->
      worker = "Worker #{id}"
      MySupervisor.start_child(worker)
    end)|> List.to_tuple

    {:ok, {workers, 0}}
  end

  @spec distribute_data(any) :: any
  def distribute_data(data) do
      workers = get_workers(Root)
      id = get_id(Root)

      IO.inspect id
      IO.inspect elem(workers, id-1)
      elem(workers, id-1) |> Forecast.create_forecast(data)
  end

  @spec get_workers(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def get_workers(root) do
    GenServer.call(root, :get_workers)
  end

  def get_id(root) do
    GenServer.call(root, :get_id)
  end

  @impl true
  def handle_call(atom, _, root) do
    cond do
      atom == :get_workers ->
        workers = elem(root, 0)
        {:reply, workers, {workers, elem(root, 1)}}

      atom == :get_id ->
        id = elem(root, 1)

        if id < tuple_size(elem(root, 0)) do
          id = id + 1
          {:reply, id, {elem(root, 0), id}}
        else
          id = 1
          {:reply, id, {elem(root, 0), id}}
        end
    end
  end

end
