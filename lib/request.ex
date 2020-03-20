defmodule Request do
 def start_link(url) do
    pid = spawn_link(__MODULE__, getData(), [])
    EventsourceEx.new(url, stream_to: pid)
  end

  @spec getData :: no_return
  def getData() do
    receive do
        msg ->
          try do
            msg = (Poison.decode!(msg.data))
            Calculate.calculateAvg(msg)
          rescue
            Poison.SyntaxError -> IO.inspect msg.data
          end
      getData()
    end
  end

end
