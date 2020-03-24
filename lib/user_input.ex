defmodule User_Input do
  def start_link do
    IO.inspect "For updating the interval of collected data press u"
    IO.inspect "Default it is 1 second"
    pid = spawn_link(__MODULE__, :get_user_input, [])
    Printer.start_printing(Printer)

    {:ok, pid}
  end

  def get_user_input do
    user_input = IO.gets("")

    if user_input === "u\n" do
      Printer.stop_printing(Printer)
      seconds =
        IO.gets("The wanted interval of seconds for updating the forecast: ") |>
        String.trim("\n") |>
        Float.parse |>
        elem(0)

      new_update_interval = seconds * 1000 |> trunc

      Aggregator.update_interval(Aggregator, new_update_interval)
      Printer.start_printing(Printer)
    end

    get_user_input()
  end
end
