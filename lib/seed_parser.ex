defmodule SeedParser do
  @moduledoc "extracted raid metadata struct"
  @type type ::
          :starlight_rose
          | :mix
          | :foxflower

  @type t :: %__MODULE__{
          date: Date.t(),
          time: Time.t(),
          seeds: integer,
          type: type
        }

  defstruct [:date, :time, :seeds, :type]
end
