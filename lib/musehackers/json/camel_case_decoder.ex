defmodule Musehackers.Json.CamelCaseDecoder do
  @moduledoc """
  A plug to convert all the keys in a map from `camelCase` to `snake_case`.
  If the map is a struct with no `Enumerable` implementation,
  the struct is considered to be a single value.
  """  
  def init(opts), do: opts

  def call(%{params: params} = conn, _opts) do
    %{conn | params: to_snake_case(params)}
  end

  defp to_snake_case(map) when is_map(map) do
    try do
      for {key, val} <- map,
        into: %{},
        do: {snake_case(key), to_snake_case(val)}
    rescue
      # Not Enumerable
      Protocol.UndefinedError -> map
    end
  end

  defp to_snake_case(list) when is_list(list),
  	do: list |> Enum.map(&to_snake_case/1)
  defp to_snake_case(other_types),
  	do: other_types

  defp snake_case(val) when is_atom(val),
  	do: val |> Atom.to_string |> Macro.underscore
  defp snake_case(val) when is_integer(val) or is_float(val),
  	do: val
  defp snake_case(val),
    do: val |> Macro.underscore

end
