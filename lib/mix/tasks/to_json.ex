defmodule Mix.Tasks.Template.ToJson do
  @moduledoc false

  use Mix.Task

  alias SeedParser.Decoder
  alias Poison.Encoder

  def run(filename) do
    {:ok, template} = File.read(filename)
    {:ok, informations} = Decoder.decode(template)

    informations
    |> Encoder.encode(pretty: true)
    |> IO.puts()
  end
end
