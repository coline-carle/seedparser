defmodule Mix.Tasks.Discord.ParsePins do
  @moduledoc false

  alias Nostrum.Api
  require Logger
  alias Poison.Encoder
  alias SeedParser.Decoder

  def parse_pin(message) do
    IO.puts("MESSAGE")
    IO.puts("-------")

    message.content
    |> IO.puts()

    case Decoder.decode(message.content) do
      {:ok, informations} ->
        IO.puts("metadata")
        IO.puts("-------")

        informations
        |> inspect()
        |> IO.puts()

        IO.puts("\n")
        IO.puts("\n")

      {:error, error} ->
        IO.puts("metadata")
        IO.puts("-------")
        IO.puts("cannot parse metadata, error: #{error}")
        IO.puts("\n")
        IO.puts("\n")
    end
  end

  def run([channel_id]) do
    [:nostrum]
    |> Enum.each(&Application.ensure_all_started/1)

    channel_id
    |> String.to_integer()
    |> Api.get_pinned_messages!()
    |> Enum.each(&parse_pin/1)
  end

  def run(_), do: IO.puts("provide channel id as parameter")
end
