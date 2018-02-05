defmodule Mix.Tasks.Discord.ParsePins do
  @moduledoc false

  alias Nostrum.Api
  require Logger
  alias Poison.Encoder
  alias SeedParser.Decoder

  def parse_pin(message) do
    File.write("pins/#{message.id}.original", message.content)

    case Decoder.decode(message.content) do
      {:ok, informations} ->
        json_data =
          informations
          |> Encoder.encode(pretty: true)

        File.write("pins/#{message.id}.json", json_data)

      _ ->
        :dontsave
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
end
