defmodule Aggregator do
  use GenServer

  def start_link(collect_interval) do
    GenServer.start_link(__MODULE__, collect_interval, name: __MODULE__)
  end

  def send_forecast(aggregator_pid, forecast_sensor_tuple) do
    GenServer.cast(aggregator_pid, {:collect_forecast, forecast_sensor_tuple})
  end

  def update_interval(aggregator_pid, new_interval) do
    GenServer.cast(aggregator_pid, {:update_interval, new_interval})
  end

  @impl true
  def init(collect_interval) do
    IO.inspect "Starting Aggregator"
    Process.send_after(self(), :send_forecast, collect_interval)

    {:ok, {[], collect_interval}}
  end

  @impl true
  def handle_info(:send_forecast, aggregator_state)do
    collect_interval = elem(aggregator_state, 1)
    forecast_map = elem(aggregator_state, 0)

    forecast =
    Calculate.sort_map(forecast_map) |>
    Calculate.get_first()

    sensors_data = Calculate.get_sensor_from_list(forecast_map, forecast)
    avg_data = calculate_avg_data(Tuple.to_list(sensors_data))

    Printer.print_forcast(Printer, {forecast, avg_data})

    Process.send_after(self(), :send_forecast, collect_interval)
    aggregator_new_state = Enum.drop(forecast_map, length(forecast_map))

    {:noreply, {aggregator_new_state, collect_interval}}
  end

  @impl true
  def handle_cast({:collect_forecast, forecast_sensor_tuple}, aggregator_state) do
    collect_interval = elem(aggregator_state, 1)
    forecast_map = elem(aggregator_state, 0)
    new_aggregator_state = forecast_map ++ [forecast_sensor_tuple]

    {:noreply, {new_aggregator_state, collect_interval}}
  end

  @impl true
  def handle_cast({:update_interval, new_collect_interval}, aggregator_state) do
    forecast_map = elem(aggregator_state, 0)

    {:noreply, {forecast_map, new_collect_interval}}
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
