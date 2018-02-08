defmodule SeedParser.Decoder do
  @moduledoc false
  defguard is_day(value) when is_integer(value) and value >= 1 and value <= 31
  defguard is_month(value) when is_integer(value) and value >= 1 and value <= 12

  alias SeedParser.Tokenizer

  @elements [:date, :seeds, :time, :type]

  def decode(data) do
    data
    |> String.split("\n")
    |> decode_line([])
    |> Enum.into(%{})
    |> validity_check
  end

  defp validity_check(metadata) do
    case metadata
         |> Map.to_list()
         |> has_all_elements? do
      true ->
        {:ok, metadata}

      false ->
        missing_error(@elements, metadata)
    end
  end

  defp missing_error([element | rest], metadata) do
    case metadata |> Map.has_key?(element) do
      true ->
        missing_error(rest, metadata)

      false ->
        {:error, "could not parse #{element}"}
    end
  end

  defp decode_line([], stack), do: stack

  defp decode_line([line | lines], stack) do
    stack =
      line
      |> Tokenizer.decode()
      |> decode_tokens(stack)

    decode_line(lines, stack)
  end

  defp decode_tokens([], stack), do: stack

  defp decode_tokens([{:type, type}, {:number, seeds} | rest], stack) do
    case stack |> Keyword.fetch(:type) do
      {:ok, _} ->
        decode_tokens(rest, stack)

      :error ->
        stack = [{:type, type}, {:seeds, seeds} | stack]
        decode_tokens(rest, stack)
    end
  end

  defp decode_tokens(
         [{:number, year}, {:punct, "/"}, {:number, month}, {:punct, "/"}, {:number, day} | rest],
         stack
       ) do
    case stack |> Keyword.fetch(:date) do
      {:ok, _} ->
        decode_tokens(rest, stack)

      :error ->
        stack = stack |> insert_if_valid_date({year, month, day})
        continue(rest, stack)
    end
  end

  defp decode_tokens([{:number, day}, {:month, month} | rest], stack) do
    case stack |> Keyword.fetch(:date) do
      {:ok, _} ->
        decode_tokens(rest, stack)

      :error ->
        now = DateTime.utc_now()
        stack = stack |> insert_if_valid_date({now.year, month, day})
        continue(rest, stack)
    end
  end

  defp decode_tokens([{:number, minute}, {:punct, ":"}, {:number, hour} | rest], stack) do
    case stack |> Keyword.fetch(:time) do
      {:ok, _} ->
        decode_tokens(rest, stack)

      :error ->
        stack = [{:time, {hour, minute, 0}} | stack]
        continue(rest, stack)
    end
  end

  defp decode_tokens([_any | tokens], stack) do
    decode_tokens(tokens, stack)
  end

  defp insert_if_valid_date(stack, {year, month, day}) when is_month(month) and is_day(day) do
    now = DateTime.utc_now()

    fullyear =
      case year do
        thisyear when thisyear < 2000 ->
          thisyear + 2000

        thisyear ->
          thisyear
      end

    case abs(now.year - fullyear) do
      delta when delta <= 1 ->
        [{:date, {fullyear, month, day}} | stack]

      _ ->
        stack
    end
  end

  defp insert_if_valid_date(stack, _), do: stack

  defp has_all_elements?(stack) do
    @elements
    |> Enum.all?(fn element -> stack |> Keyword.has_key?(element) end)
  end

  defp continue(rest, stack) do
    case stack |> has_all_elements? do
      true ->
        stack

      false ->
        decode_tokens(rest, stack)
    end
  end
end
