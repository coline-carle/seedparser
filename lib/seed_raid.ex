defmodule Seedparser.SeedRaid do
  @moduledoc """
    final representation of a seedraid
  """
  defstruct [:title, :datetime, :participants, :requirements, :type, :size, :style, :max]

  @type t :: %__MODULE__{
          title: String.t(),
          datetime: Datetime.t(),
          participants: integer,
          size: integer,
          type: raid_type,
          max: list({herb | :any, integer}),
          requirements: list({herb, rank}),
          style: style | nil
        }

  @type raid_type ::
          :starlight_rose
          | :mix
          | :foxflower

  @type datetime :: {date, time}
  @type date :: {Calendar.year(), Calendar.month(), Calendar.day()}
  @type time :: {Calendar.hour(), Calendar.minute(), Calendar.second()}

  @type rank :: integer

  @type style :: :two_phase | :wild

  @type herb ::
          :starlight_rose
          | :foxflower
          | :aethril
          | :felwort
          | :fjarnskaggl
          | :dreamleaf

  @required_keys [:title, :date, :time]

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
    acc = [informations |> transform_title() | acc]
    acc = [informations |> transform_datetime() | acc]
    acc = [informations |> transform_type() | acc]
    acc = [informations |> transform_size() | acc]
    acc = [informations |> transform_style() | acc]
    acc = [informations |> transform_requirements() | acc]
    acc = [informations |> transform_max() | acc]
    acc = [informations |> transform_participants() | acc]
    struct(__MODULE__, acc)
  end

  defp transform_title(%{title: title}) do
    {:title, title}
  end

  defp transform_max(%{max: max}) do
    {:max, max |> Map.to_list()}
  end

  defp transform_max(_) do
    {:max, nil}
  end

  defp transform_requirements(%{required: requirements}) do
    {:requirements, requirements |> Map.to_list()}
  end

  defp transform_participants(%{participants: %{count: count}}) do
    {:participants, count}
  end

  defp transform_participants(_) do
    {:participants, 0}
  end

  defp transform_style(%{style: style}) do
    {:style, style}
  end

  defp transform_style(_) do
    {:style, nil}
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
