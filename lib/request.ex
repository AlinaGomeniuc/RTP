defmodule Request do
 def start_link(url) do
    pid = spawn_link(__MODULE__, :getData, [])
    EventsourceEx.new(url, stream_to: pid)

    {:ok, pid}
  end

  @spec getData :: no_return
  def getData() do
    receive do
        msg ->
            msg = (Poison.decode!(msg.data))
            Calculate.calculateAvg(msg)

        getData()
    end
  end

end
