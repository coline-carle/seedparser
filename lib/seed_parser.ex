defmodule SeedParser do
  @moduledoc "extracted raid metadata struct"
  @type type ::
          :starlight_rose
          | :mix
          | :foxflower
          | :fjarnskaggl
          | :dreamleaf
          | :aethril

  @type t :: %__MODULE__{
          date: Date.t(),
          time: Time.t(),
          seeds: integer,
          type: type,
          roster: list(integer),
          backup: list(integer),
          participants: integer
        }

  defstruct [:date, :time, :seeds, :type, :participants, :roster, :backup]
end
