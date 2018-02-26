defmodule Mix.Tasks.Template.Parse do
  @moduledoc false

  use Mix.Task

  alias SeedParser.Decoder

  def run(filename) do
    {:ok, template} = File.read(filename)
    {:ok, informations} = Decoder.decode(template)

    informations
    |> inspect()
    |> IO.puts()
  end
end
