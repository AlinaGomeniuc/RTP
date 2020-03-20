defmodule Calculate do
  def start_link() do
  IO.inspect "aaa"
  end

  @spec calculateAvg(nil | maybe_improper_list | map) :: any
  def calculateAvg(msg) do
    items = msg["message"]
    items = getTuple(items)
    items = getMapList(items)
    getMap(items)
  end

  def getTuple(items) do
    Enum.map(items, fn {k, v} -> {Enum.at(String.split(k, "_sensor"), 0), v} end)
    |>Enum.group_by(fn {k, _y} -> {k} end)
    |>Map.values()
  end

  def getMapList(items) do
    avgMapList = Map.new()
    avgMapList =
      for item <- items do
        if length(item) == 2 do
          [{k, v}, {_a, b}] = item
          Map.put(avgMapList, k, (v + b) /2)
        else
          [{k, v}] = item
          Map.put(avgMapList, k, v)
        end
      end
      avgMapList
  end

  def getMap(mapList) do
    avgMap = Enum.reduce(mapList, fn x, y ->
      Map.merge(x, y, fn _k, v1, v2 -> v2 ++ v1 end)
    end)
    IO.inspect(avgMap)
  end

end
