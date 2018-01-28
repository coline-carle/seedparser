defmodule Mix.Tasks.Discord.FetchPins do
  @moduledoc false

  alias Nostrum.Api
  require Logger

  def save_message(message) do
    File.write("pins/#{message.id}.original", message.content)
  end

  defp ok({:ok, _}), do: true
  defp ok(_), do: false

  def get(channel_id) do
    pinned = Api.get_pinned_messages!(channel_id)

    pinned
    |> Enum.each(&save_message/1)
  end
end
