defmodule Lab1.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: MySupervisor,
        start: {MySupervisor, :start_link, []}
      },

      %{
        id: Request,
        start: {Request, :start_link, ["http://localhost:4000/iot"]},
        restart: :permanent
      }
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)

    receive do
    end
  end
end

