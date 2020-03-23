defmodule Printer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec print_forcast(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def print_forcast(printer_pid, data) do
    GenServer.cast(printer_pid, {:print_forcast, data})
  end

  @impl true
  def init(_) do
    {:ok, {}}
  end

  @impl true
  def handle_cast({:print_forcast, data}, printer_state) do
    forcast = elem(data, 0)
    sensors_data = elem(data, 1)

    humidity = sensors_data[:humidity] |> Float.round(2)
    light = sensors_data[:light] |> Float.round(2)
    pressure = sensors_data[:pressure] |> Float.round(2)
    temperature = sensors_data[:temperature] |> Float.round(2)
    wind = sensors_data[:wind] |> Float.round(2)
    timestamp = sensors_data[:timestamp] |> DateTime.from_unix(:microsecond)
                                         |> elem(1)
                                         |> DateTime.add(7200, :second)

    IO.puts ("=================================")
    IO.puts ("Date: #{timestamp.day}.#{timestamp.month}.#{timestamp.year} | Time: #{timestamp.hour}:#{timestamp.minute}:#{timestamp.second}")
    IO.puts ("---------------------------------")
    IO.puts ("IT'S #{forcast} OUTSIDE")
    IO.puts ("---------------------------------")
    IO.puts ("Humidity: #{humidity}")
    IO.puts ("Light: #{light}")
    IO.puts ("Pressure: #{pressure}")
    IO.puts ("Temperature: #{temperature}")
    IO.puts ("Wind: #{wind}")
    IO.puts ("=================================")
    IO.puts ("")

    {:noreply, printer_state}
  end
end
