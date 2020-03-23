defmodule Aggregator do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def send_forecast(aggregator_pid, forecast_sensor_tuple) do
    GenServer.cast(aggregator_pid, {:collect_forecast, forecast_sensor_tuple})
  end

  @impl true
  def init(_) do
    IO.inspect "Starting Aggregator"
    Process.send_after(self(), :send_forecast, 1000)

    {:ok, []}
  end

  @impl true
  def handle_info(:send_forecast, aggregator_state)do
    forecast =
    Calculate.sort_map(aggregator_state) |>
    Calculate.get_first()

    sensors_data = Calculate.get_sensor_from_list(aggregator_state, forecast)
    avg_data = calculate_avg_data(Tuple.to_list(sensors_data))

    Printer.print_forcast(Printer, {forecast, avg_data})

    Process.send_after(self(), :send_forecast, 1000)
    aggregator_new_state = Enum.drop(aggregator_state, length(aggregator_state))

    {:noreply, aggregator_new_state}
  end

  @impl true
  def handle_cast({:collect_forecast, forecast_sensor_tuple}, aggregator_state) do
    new_aggregator_state = aggregator_state ++ [forecast_sensor_tuple]

    {:noreply, new_aggregator_state}
  end

  defp calculate_avg_data(sensor_list_data) do
    pressure = Calculate.sum_data(sensor_list_data, "atmo_pressure") / length(sensor_list_data)
    humidity = Calculate.sum_data(sensor_list_data, "humidity") / length(sensor_list_data)
    light = Calculate.sum_data(sensor_list_data, "light") / length(sensor_list_data)
    wind_speed = Calculate.sum_data(sensor_list_data, "wind_speed") / length(sensor_list_data)
    temperature = Calculate.sum_data(sensor_list_data, "temperature") / length(sensor_list_data)
    timestamp = Calculate.last_element(sensor_list_data, "unix_timestamp_us")

    result = %{
      humidity: humidity,
      light: light,
      pressure: pressure,
      temperature: temperature,
      wind: wind_speed,
      timestamp: timestamp
    }
    result
  end

end
