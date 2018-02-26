defmodule SeedParser.Normalizer do
  @moduledoc false

  @tokens %{
    "am" => {:day_period, :am},
    "pm" => {:day_period, :pm},
    "backup" => {:token, :backup},
    "backups" => {:token, :backup},
    "standby" => {:token, :backup},
    "stand-by" => {:token, :backup},
    "stand" => {:token, :stand},
    "by" => {:token, :by},
    "upcoming" => {:token, :upcoming},
    "scheduled" => {:token, :upcoming},
    "events" => {:token, :events},
    "raids" => {:token, :events},
    "est" => {:timezone, :est},
    "cet" => {:timezone, :cet},
    "ff" => {:type, :foxflower},
    "fox" => {:type, :foxflower},
    "foxflower" => {:type, :foxflower},
    "fjarnskaggl" => {:type, :fjarnksaggl},
    "fj" => {:type, :fjranskaggl},
    "dreamleaf" => {:type, :dremleaf},
    "dl" => {:type, :dreamleaf},
    "mix" => {:type, :mix},
    "mixed" => {:type, :mix},
    "slr" => {:type, :starlight_rose},
    "starlight" => {:type, :starlight_rose},
    "monday" => {:weekday, 0},
    "tuesday" => {:weekday, 1},
    "wednesday" => {:weekday, 2},
    "thursday" => {:weekday, 3},
    "friday" => {:weekday, 4},
    "saturday" => {:weekday, 5},
    "sunday" => {:weekday, 6},
    "january" => {:month, 1},
    "jan" => {:month, 1},
    "february" => {:month, 2},
    # parse this typo
    "febuary" => {:month, 2},
    "feb" => {:month, 2},
    "march" => {:month, 3},
    "mar" => {:month, 3},
    "april" => {:weekday, 4},
    "apr" => {:weekday, 4},
    "may" => {:month, 5},
    "june" => {:month, 6},
    "jun" => {:month, 6},
    "july" => {:month, 7},
    "august" => {:month, 8},
    "aug" => {:month, 8},
    "september" => {:month, 9},
    "sept" => {:month, 9},
    "october" => {:month, 10},
    "oct" => {:month, 10},
    "november" => {:month, 11},
    "nov" => {:month, 11},
    "december" => {:month, 12},
    "dec" => {:month, 12}
  }

  @type token ::
          :type
          | :weeekday
          | :month

  @spec normalize(binary()) :: token | :invalid
  def normalize(value) do
    dvalue = value |> String.downcase()

    @tokens |> Map.get(dvalue, :text)
  end
end
