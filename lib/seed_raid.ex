defmodule SeedParser.SeedRaid do
  @moduledoc """
    final representation of a seedraid
  """
  defstruct [:datetime, :type, :size, :content]

  @type t :: %__MODULE__{
          datetime: Datetime.t(),
          size: integer,
          type: raid_type,
          content: String.t()
        }

  @type raid_type ::
          :starlight_rose
          | :mix
          | :foxflower

  @type datetime :: {date, time}
  @type date :: {Calendar.year(), Calendar.month(), Calendar.day()}
  @type time :: {Calendar.hour(), Calendar.minute(), Calendar.second()}

  @type herb ::
          :starlight_rose
          | :foxflower
          | :aethril
          | :felwort
          | :fjarnskaggl
          | :dreamleaf

  @required_keys [:date, :time]

  def transform(informations) do
    case @required_keys
         |> Enum.all?(fn key ->
           informations |> Map.has_key?(key)
         end) do
      true -> do_transform(informations)
      _ -> :error
    end
  end

  defp do_transform(informations) do
    acc = []
    acc = [informations |> transform_datetime() | acc]
    acc = [informations |> transform_type() | acc]
    acc = [informations |> transform_size() | acc]
    struct(__MODULE__, acc)
  end

  defp transform_type(%{title_tokens: [token | []]}) do
    {:type, token}
  end

  defp transform_type(%{max_tokens: [token | []]}) do
    {:type, token}
  end

  defp transform_size(%{seeds: %{quantity: quantity}}) do
    {:size, quantity}
  end

  defp transform_datetime(%{date: date, time: time}) do
    now = DateTime.utc_now()
    year = date |> Map.get(:year, now.year)

    year_diff = abs(now.year - year)

    year =
      case year_diff do
        year_diff when year_diff < 2 ->
          year

        year_diff when year_diff - 2000 < 2 ->
          year + 2000

        _ ->
          now.year
      end

    {:datetime, {{year, date[:month], date[:day]}, {time[:hour], time[:minute], 0}}}
  end
end
