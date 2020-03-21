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

  def distribute_data(data, root) do
      workers = elem(root, 0)
      id = get_id(root)
      # IO.inspect elem(workers, id-1)
      elem(workers, id-1) |> Forecast.create_forecast(data)
      {elem(root, 0), id}
  end

  def get_data(data, root) do
    GenServer.cast(data, root)
  end

  @impl true
  def handle_cast(data, root) do
    root = distribute_data(data, root)
    {:noreply, root}
  end

  def get_id(root)do
    id = elem(root, 1)
    id =
    if id < tuple_size(elem(root, 0)) do
      id + 1  else  1
    end
    id
  end
end
