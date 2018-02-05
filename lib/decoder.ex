defmodule SeedParser.DecodeError do
  @type t :: %__MODULE__{position: integer, data: String.t()}

  defexception [:position, :data]

  def message(%{position: position, data: data}) when position == byte_size(data) do
    "unexpected end of input at position #{position}"
  end

  def message(%{position: position, data: data}) do
    byte = :binary.at(data, position)
    str = <<byte>>

    if String.printable?(str) do
      "unexpected byte at position #{position}: " <> "#{inspect(byte, base: :hex)} ('#{str}')"
    else
      "unexpected byte at position #{position}: " <> "#{inspect(byte, base: :hex)}"
    end
  end
end

defmodule SeedParser.Decoder do
  @moduledoc false

  alias SeedParser.DecodeError
  alias SeedParser.SeedRaid
  alias SeedParser.Normalizer
  alias SeedParser.Element.{Style, Date, Max, Participants, Required, Seeds, Time, TypeToken}

  # We use integers instead of atoms to take advantage of the jump table
  # optimization
  @title 0
  @key 1
  @value 2
  @participants 3

  # @letters 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  @digits '01234556789'
  @default_options [transform: true]

  def decode_title([]), do: :empty

  def decode_title([line | lines]) do
    case title(line, line, 0, []) do
      :notfound ->
        decode_title(lines)

      {:title, title} ->
        {:ok, tokens} = TypeToken.decode(title)

        informations =
          case tokens do
            [] ->
              %{title: title}

            tokens ->
              %{title: title, title_tokens: tokens}
          end

        decode_keyvalues(lines, informations)
    end
  end

  defp decode_keyvalues([], informations) do
    informations
  end

  defp decode_keyvalues([line | lines], informations) do
    case key(line, line, 0, []) do
      :notfound ->
        decode_keyvalues(lines, informations)

      {key, value} ->
        {nkey, nvalue} =
          {key, value}
          |> Normalizer.normalize()
          |> decode_field

        informations = informations |> Map.put_new(nkey, nvalue)
        decode_keyvalues(lines, informations)
    end
  end

  def decode(data, options \\ @default_options) do
    lines = data |> String.split("\n")

    try do
      decode_title(lines)
    catch
      {:position, position} ->
        {:error, %DecodeError{position: position, data: data}}
    else
      :empty ->
        {:error, :empty}

      value ->
        case options |> Keyword.fetch(:transform) do
          {:ok, true} ->
            {:ok, value |> SeedRaid.transform()}

          _ ->
            {:ok, value}
        end
    end
  end

  def decode_field({:date, date}) do
    case date |> Date.decode() do
      {:ok, value} ->
        {:date, value}

      {:error, error} ->
        {:date, {:error, error}}
    end
  end

  def decode_field({:time, time}) do
    case time |> Time.decode() do
      {:ok, value} ->
        {:time, value}

      {:error, error} ->
        {:time, {:error, error}}
    end
  end

  def decode_field({:style, style}) do
    case style |> Style.decode() do
      {:ok, value} ->
        {:time, value}

      {:error, error} ->
        {:time, {:error, error}}
    end
  end

  def decode_field({:seeds, seeds}) do
    case seeds |> Seeds.decode() do
      {:ok, value} ->
        {:seeds, value}

      {:error, error} ->
        {:seeds, {:error, error}}
    end
  end

  def decode_field({:required, seeds}) do
    case seeds |> Required.decode() do
      {:ok, value} ->
        {:required, value}

      {:error, error} ->
        {:required, {:error, error}}
    end
  end

  def decode_field({:participants, seeds}) do
    case seeds |> Participants.decode() do
      {:ok, value} ->
        {:participants, value}

      {:error, error} ->
        {:participants, {:error, error}}
    end
  end

  def decode_field({:max, seeds}) do
    case seeds |> Max.decode() do
      {:ok, value} when is_map(value) ->
        {:max, value}

      {:ok, value} when is_list(value) ->
        {:max_tokens, value}

      {:ok, value} ->
        {:max, {:error, value}}

      {:error, error} ->
        {:max, {:error, error}}
    end
  end

  def decode_field({field, value}) do
    {field, value}
  end

  defp error(_original, skip) do
    throw({:position, skip})
  end

  defp key(<<byte, rest::bits>>, original, skip, stack) when byte in ' \s\t*' do
    key(rest, original, skip + 1, stack)
  end

  defp key(<<?[, rest::bits>>, original, skip, stack) do
    bracket(rest, original, skip + 1, [@key | stack], 0)
  end

  defp key(<<?(, byte, rest::bits>>, original, skip, stack) when byte in @digits do
    paren(rest, original, skip + 1, [@participants | stack], 1)
  end

  defp key(<<_::bits>>, _original, _skip, _stack) do
    :notfound
  end

  defp key(rest, original, skip, stack, value) do
    value(rest, original, skip, [{:key, value} | stack])
  end

  defp value(<<byte, rest::bits>>, original, skip, stack) when byte in ' \s\t' do
    value(rest, original, skip + 1, stack)
  end

  defp value(<<?(, rest::bits>>, original, skip, stack) do
    paren(rest, original, skip + 1, [@value | stack], 0)
  end

  defp value(<<>>, original, skip, _stack) do
    error(original, skip)
  end

  defp participants(_rest, _original, _skip, _stack, value) do
    {:participants, value}
  end

  defp value(_rest, _original, _skip, stack, value) do
    [{:key, key}] = stack
    {key, value}
  end

  defp title(<<byte, rest::bits>>, original, skip, stack) when byte in ' \s\t' do
    title(rest, original, skip + 1, stack)
  end

  defp title(<<?<, rest::bits>>, original, skip, stack) do
    uneven(rest, original, skip + 1, [@title | stack], 0)
  end

  defp title(<<?[, rest::bits>>, original, skip, stack) do
    bracket(rest, original, skip + 1, [@title | stack], 0)
  end

  defp title(<<_::bits>>, _original, _skip, _stack) do
    :notfound
  end

  defp title(_rest, _original, _skip, _stack, value) do
    {:title, value}
  end

  defp paren(<<?), rest::bits>>, original, skip, stack, len) do
    value = binary_part(original, skip, len)
    continue(rest, original, skip + 1 + len, stack, value)
  end

  defp paren(<<_, rest::bits>>, original, skip, stack, len) do
    paren(rest, original, skip, stack, len + 1)
  end

  defp paren(<<_::bits>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp bracket(<<?], rest::bits>>, original, skip, stack, len) do
    value = binary_part(original, skip, len)
    continue(rest, original, skip + 1 + len, stack, value)
  end

  defp bracket(<<_, rest::bits>>, original, skip, stack, len) do
    bracket(rest, original, skip, stack, len + 1)
  end

  defp bracket(<<_::bits>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp uneven(<<?>, rest::bits>>, original, skip, stack, len) do
    value = binary_part(original, skip, len)
    continue(rest, original, skip + 1 + len, stack, value)
  end

  defp uneven(<<_, rest::bits>>, original, skip, stack, len) do
    uneven(rest, original, skip, stack, len + 1)
  end

  defp uneven(<<_::bits>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp continue(rest, original, skip, stack, value) do
    case stack do
      [@key | stack] ->
        key(rest, original, skip, stack, value)

      [@value | stack] ->
        value(rest, original, skip, stack, value)

      [@title | stack] ->
        title(rest, original, skip, stack, value)

      [@participants | stack] ->
        participants(rest, original, skip, stack, value)
    end
  end
end
