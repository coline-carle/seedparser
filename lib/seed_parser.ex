defmodule SeedParser do
  @moduledoc "struct format"
  @type type ::
          :starlight_rose
          | :mix
          | :foxflower

  @type t :: %__MODULE__{
          date: Date.t(),
          time: Time.t(),
          seeds: integer,
          type: type,
          content: binary()
        }

  defstruct [:date, :time, :seeds, :type, :content]
end
