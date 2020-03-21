defmodule Agregator do
  use GenServer

  def start_link(time) do
    GenServer.start_link(__MODULE__, time, name: __MODULE__)
  end

  @impl true
  def init(time) do
    IO.inspect "Agregator for #{time}"
    {:ok, time}
  end

  def receive_data(data) do
    time = get_time()
    # IO.inspect time
    # IO.inspect data
  end

  def get_time() do
    GenServer.call(Agregator, :get_time)
  end

  @impl true
  def handle_call(:get_time, _, agregator) do
    time = agregator
    {:reply, time, agregator}
  end
end
