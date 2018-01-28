defmodule Mix.Tasks.Template.ToJson do
  use Mix.Task

  alias Seedparser.Decoder

  def run(filename) do
    {:ok, template} = File.read(filename)
    {:ok, informations} = Decoder.decode(template)

    informations
    |> Poison.Encoder.encode(pretty: true)
    |> IO.puts()
  end
end
