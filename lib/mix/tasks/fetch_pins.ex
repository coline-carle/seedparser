defmodule Mix.Tasks.Discord.FetchPins do
  @moduledoc false

  alias Nostrum.Api
  require Logger

  def save_message(message) do
    File.write("pins/#{message.id}.original", message.content)
  end

  def run(channel_id) do
    [:nostrum]
    |> Enum.each(&Application.ensure_all_started/1)

    pinned = Api.get_pinned_messages!(channel_id)

    pinned
    |> Enum.each(&save_message/1)
  end
end
