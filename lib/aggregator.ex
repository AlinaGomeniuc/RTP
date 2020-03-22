defmodule Aggregator do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    IO.inspect "Starting Aggregator"
    Process.send_after(self(), :send_forecast, 1000)

    {:ok, []}
  end

  def receive_data(aggregator, data) do
    GenServer.cast(aggregator, {:get_forecast, data})
  end

  @impl true
  def handle_info(:send_forecast, aggregator)do
    forecast =
    Calculate.sort_map(aggregator) |>
    Calculate.get_first()

    sensors_data = Calculate.get_sensor_from_list(aggregator, forecast)

    avg_data = calculate_avg_data(Tuple.to_list(sensors_data))

    Printer.print_forcast(Printer, {forecast, avg_data})

    Process.send_after(self(), :send_forecast, 1000)

    {:noreply, []}
  end

  @impl true
  def handle_cast({:get_forecast, data}, aggregator) do
    newAggregator = aggregator ++ [data]

    {:noreply, newAggregator}
  end

  defp calculate_avg_data(list) do
    pressure = Calculate.sum_data(list, "atmo_pressure") / length(list)
    humidity = Calculate.sum_data(list, "humidity") / length(list)
    light = Calculate.sum_data(list, "light") / length(list)
    wind_speed = Calculate.sum_data(list, "wind_speed") / length(list)
    temperature = Calculate.sum_data(list, "temperature") / length(list)

    result = %{
      humidity: humidity,
      light: light,
      pressure: pressure,
      temperature: temperature,
      wind: wind_speed
    }
    result
  end

end
