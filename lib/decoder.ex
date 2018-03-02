defmodule SeedParser.Decoder do
  @moduledoc false
  require Logger

  alias SeedParser.Tokenizer

  @elements [:date, :seeds, :time, :type]
  @type type ::
          :starlight_rose
          | :mix
          | :foxflower
  @type seeds :: integer

  @seed_range 20..400

  @participants_range 1..15

  def decode(data, options \\ []) do
    defaults = [today: Date.utc_today(), date: :eu]

    options =
      defaults
      |> Keyword.merge(options)
      |> Enum.into(%{})

    metadata =
      data
      |> Tokenizer.decode()
      |> decode_tokens([roster: MapSet.new()], options)
      |> Enum.into(%{})

    case metadata do
      %{error: error} ->
        {:error, error}

      _ ->
        metadata
        |> validity_check()
    end
  end

  def format(data) do
    Regex.replace(~r/\n?\s*(```[a-z]*)\s*\n?/, data, "\n\\1\n")
  end

  defp validity_check(metadata) do
    case metadata
         |> Map.to_list()
         |> has_all_elements? do
      true ->
        {:ok, struct(%SeedParser{}, metadata |> sets_to_list())}

      false ->
        missing_error(@elements, metadata)
    end
  end

  defp missing_error(elements, metadata) do
    missing = missing_elements(elements, metadata, [])
    {:error, %{missing: missing}}
  end

  defp missing_elements([], _metadata, missing), do: missing

  defp missing_elements([element | rest], metadata, missing) do
    case metadata |> Map.has_key?(element) do
      true ->
        missing_elements(rest, metadata, missing)

      false ->
        missing_elements(rest, metadata, [element | missing])
    end
  end

  defp decode_tokens([], stack, _), do: stack

  defp decode_tokens([{:token, :events}, {:token, :upcoming} | _], _stack, _options) do
    [error: :upcoming]
  end

  defp decode_tokens([{:user, discord_id} | rest], stack, options) do
    stack = stack |> add_user(discord_id)

    decode_tokens(rest, stack, options)
  end

  defp decode_tokens([{:type, type}, {:number, seeds} | rest], stack, options)
       when seeds in @seed_range do
    stack =
      stack
      |> Keyword.put(:type, type)
      |> Keyword.put(:seeds, seeds)

    decode_tokens(rest, stack, options)
  end

  defp decode_tokens(
         [{:number, 10}, {:punct, "/"}, {:number, participants} | rest],
         stack,
         options
       )
       when participants in @participants_range do
    stack =
      stack
      |> Keyword.put(:participants, participants)

    decode_tokens(rest, stack, options)
  end

  defp decode_tokens([{:number, seeds}, {:type, type} | rest], stack, options)
       when seeds in @seed_range do
    stack =
      stack
      |> Keyword.put(:type, type)
      |> Keyword.put(:seeds, seeds)

    decode_tokens(rest, stack, options)
  end

  defp decode_tokens(
         [
           {:number, year},
           {:punct, punct},
           {:number, month},
           {:punct, punct},
           {:number, day} | rest
         ],
         stack,
         %{date: :eu} = options
       ) do
    stack = stack |> insert_if_valid_date(year, month, day, options)
    continue(rest, stack, options)
  end

  defp decode_tokens(
         [
           {:number, year},
           {:punct, punct},
           {:number, day},
           {:punct, punct},
           {:number, month} | rest
         ],
         stack,
         %{date: :na} = options
       ) do
    stack = stack |> insert_if_valid_date(year, month, day, options)
    continue(rest, stack, options)
  end

  defp decode_tokens(
         [
           {:number, month},
           {:punct, _},
           {:number, day},
           {:punct, ","},
           {:weekday, _weekday} | rest
         ],
         stack,
         %{today: today} = options
       ) do
    stack = stack |> insert_if_valid_date(today.year, month, day, options)
    continue(rest, stack, options)
  end

  defp decode_tokens(
         [
           {:number, month},
           {:punct, _},
           {:number, day},
           {:weekday, _weekday} | rest
         ],
         stack,
         %{today: today} = options
       ) do
    stack = stack |> insert_if_valid_date(today.year, month, day, options)
    continue(rest, stack, options)
  end

  defp decode_tokens(
         [
           {:timezone, _any},
           {:day_period, day_period},
           {:number, minute},
           {:punct, ":"},
           {:number, hour} | rest
         ],
         stack,
         options
       ) do
    hour =
      case day_period do
        :am ->
          hour

        :pm ->
          hour + 12
      end

    stack = stack |> insert_if_valid_time(hour, minute)
    continue(rest, stack, options)
  end

  defp decode_tokens(
         [{:timezone, _any}, {:number, minute}, {:punct, ":"}, {:number, hour} | rest],
         stack,
         options
       ) do
    stack = stack |> insert_if_valid_time(hour, minute)
    continue(rest, stack, options)
  end

  defp decode_tokens([{:number, minute}, {:punct, ":"}, {:number, hour} | rest], stack, options) do
    stack = stack |> insert_if_valid_time(hour, minute)
    continue(rest, stack, options)
  end

  defp decode_tokens([{:timezone, :est}, {:number, combined} | rest], stack, options) do
    hour = div(combined, 100)
    minute = rem(combined, 100)
    stack = stack |> insert_if_valid_time(hour, minute)
    continue(rest, stack, options)
  end

  defp decode_tokens([{:day_period, day_period}, {:number, hour} | rest], stack, options) do
    hour =
      case day_period do
        :am ->
          hour

        :pm ->
          hour + 12
      end

    stack = stack |> insert_if_valid_time(hour, 00)
    continue(rest, stack, options)
  end

  defp decode_tokens([{:number, day}, {:month, month} | rest], stack, %{today: today} = options) do
    stack = stack |> insert_if_valid_date(today.year, month, day, options)
    continue(rest, stack, options)
  end

  defp decode_tokens([{:token, :by}, {:token, :stand} | rest], stack, options) do
    stack = switch_roster_and_backup(stack)
    continue(rest, stack, options)
  end

  defp decode_tokens([{:token, :backup} | rest], stack, options) do
    stack = switch_roster_and_backup(stack)
    continue(rest, stack, options)
  end

  defp decode_tokens([_any | tokens], stack, options) do
    decode_tokens(tokens, stack, options)
  end

  defp switch_roster_and_backup(stack) do
    roster = stack |> Keyword.fetch!(:roster)

    stack
    |> Keyword.put(:backup, roster)
    |> Keyword.put(:roster, MapSet.new())
  end

  defp add_user(stack, discord_id) do
    roster_set = stack |> Keyword.fetch!(:roster)

    case stack |> Keyword.fetch(:backup) do
      {:ok, backup_set} ->
        case backup_set |> MapSet.member?(discord_id) do
          true ->
            stack

          false ->
            roster_set = roster_set |> MapSet.put(discord_id)

            stack
            |> Keyword.put(:roster, roster_set)
        end

      :error ->
        roster_set =
          roster_set
          |> MapSet.put(discord_id)

        stack
        |> Keyword.put(:roster, roster_set)
    end
  end

  defp set_to_list(stack, key) do
    {key,
     stack
     |> Map.fetch!(key)
     |> MapSet.to_list()}
  end

  defp sets_to_list(stack) do
    stack = stack |> Map.put_new(:backup, MapSet.new())

    set_map =
      [:backup, :roster]
      |> Enum.map(&set_to_list(stack, &1))
      |> Enum.into(%{})

    Map.merge(stack, set_map)
  end

  defp insert_if_valid_time(stack, hour, minute) do
    case Time.new(hour, minute, 0) do
      {:ok, time} ->
        [{:time, time} | stack]

      _ ->
        stack
    end
  end

  defp insert_if_valid_date(stack, year, month, day, %{today: today}) do
    fullyear =
      case year do
        thisyear when thisyear < 2000 ->
          thisyear + 2000

        thisyear ->
          thisyear
      end

    case Date.new(fullyear, month, day) do
      {:ok, date} ->
        case Date.diff(date, today) do
          days when days in -7..45 ->
            [{:date, date} | stack]

          _ ->
            stack
        end

      _ ->
        stack
    end
  end

  defp has_all_elements?(stack) do
    @elements
    |> Enum.all?(fn element -> stack |> Keyword.has_key?(element) end)
  end

  defp continue(rest, stack, options) do
    decode_tokens(rest, stack, options)
  end
end
