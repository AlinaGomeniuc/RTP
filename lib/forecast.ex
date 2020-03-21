defmodule Forecast do
  use GenServer

  def start_link(name) do
  IO.inspect "Starting forecast"
  GenServer.start_link(__MODULE__, [name], name: get_worker(name))
  end

  def init(name) do
    IO.inspect "Starting #{name}"
    {:ok, name}
  end

  def create_forecast(_worker, msg) do
      data = Poison.decode!(msg.data)
      IO.inspect data
      # avgWeather = Calculate.calculateAvg(data)
      # forecast = forecast(avgWeather)
      # Agregator.receive_data(forecast)

      # IO.inspect avgWeather
      # IO.inspect forecast
  end

  # def handle_cast() do

  # end

  def forecast(avgWeather) do
    pressure = avgWeather["atmo_pressure"]
    temperature = avgWeather["temperature"]
    light = avgWeather["light"]
    wind = avgWeather["wind_speed"]
    humidity = avgWeather["humidity"]
    cond do
      temperature < -2 && light < 128 && pressure < 720 -> "SNOW"
      temperature < -2 && light > 128 && pressure < 680 -> "WET_SNOW"
      temperature < -8 -> "SNOW"
      temperature < -15 && wind > 45 -> "BLIZZARD"
      temperature > 0 && pressure < 710 && humidity > 70 && wind < 20 -> "SLIGHT_RAIN"
      temperature > 0 && pressure < 690 && humidity > 70 && wind > 20 -> "HEAVY_RAIN"
      temperature > 30 && pressure < 770 && humidity > 80 && light > 192 -> "HOT"
      temperature > 30 && pressure < 770 && humidity > 50 && light > 192 && wind > 35 -> "CONVECTION_OVEN"
      temperature > 25 && pressure < 750 && humidity > 70 && light < 192 && wind < 10 -> "WARM"
      temperature > 25 && pressure < 750 && humidity > 70 && light < 192 && wind > 10 -> "SLIGHT_BREEZE"
      light < 128 -> "CLOUDY"
      temperature > 30 && pressure < 660 && humidity > 85 && wind > 45 -> "MONSOON"
      true -> "JUST_A_NORMAL_DAY"
    end
  end

  defp get_worker(name) do
    {:via, Registry, {:workers_registry, name}}
  end

end
