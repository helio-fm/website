defmodule Musehackers.JSONEncoder do
  @moduledoc false
  def encode_to_iodata!(data) do
    data
    |> ProperCase.to_camel_case
    |> Jason.encode_to_iodata!
  end
end
