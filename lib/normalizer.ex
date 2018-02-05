defmodule SeedParser.Normalizer do
  @moduledoc false

  @keys %{
    "date:" => :date,
    "time:" => :time,
    "req:" => :required,
    "max:" => :max,
    "seeds:" => :seeds,
    "style:" => :style,
    "at" => :aethril,
    "fw" => :felwort,
    "ff" => :foxflower,
    "of" => :any
  }
  @values %{
    "monday" => 0,
    "tuesday" => 1,
    "wednesday" => 2,
    "thursday" => 3,
    "friday" => 4,
    "saturday" => 5,
    "sunday" => 6,
    "january" => 1,
    "february" => 2,
    "march" => 3,
    "april" => 4,
    "may" => 5,
    "june" => 6,
    "july" => 7,
    "august" => 8,
    "september" => 9,
    "october" => 10,
    "november" => 11,
    "december" => 12
  }

  def normalize(value, list) when is_binary(value) do
    dvalue = value |> String.downcase()

    list |> Map.get(dvalue, value)
  end

  def normalize(value, _list), do: value

  def normalize({key, value}) do
    value = value |> normalize(@values)
    key = key |> normalize(@keys)
    {key, value}
  end

  def normalize(list) when is_list(list) do
    list
    |> Enum.map(fn tuple -> normalize(tuple) end)
  end
end
