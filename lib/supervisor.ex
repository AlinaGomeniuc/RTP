defmodule MySupervisor do
  use DynamicSupervisor
  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(name) do
    children = %{
      id: Forecast,
      start: {Forecast, :start_link, [name]},
    }

    DynamicSupervisor.start_child(__MODULE__,children)
  end
end
