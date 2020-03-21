defmodule Request do
 def start_link(url) do
    IO.inspect "Starting request"
    pid = spawn_link(__MODULE__, :getData, [])
    EventsourceEx.new(url, stream_to: pid)

    {:ok, pid}
  end

  def getData() do
    receive do
        msg ->
            # msg = (Poison.decode!(msg.data))
            Root.distribute_data(msg)
            # Process.sleep(100)
    end
    getData()
  end
end
