defmodule Musehackers.JSONEncoder do
  @moduledoc """
  Converts all the keys in a map to `camelCase`.
  If the map is a struct with no `Enumerable` implementation,
  the struct is considered to be a single value.
  """  
  def encode_to_iodata!(data) do
    data
    |> to_camel_case
    |> Jason.encode_to_iodata!
  end

  defp to_camel_case(map) when is_map(map) do
    try do
      for {key, val} <- map,
        into: %{},
        do: {camelize(key), to_camel_case(val)}
    rescue
      Protocol.UndefinedError -> map # Not Enumerable
    end
  end

  defp to_camel_case(list) when is_list(list),
    do: list |> Enum.map(&to_camel_case/1)
  defp to_camel_case(final_val),
    do: final_val

  defp camelize(key) when is_atom(key),
    do: key |> Atom.to_string |> camelize
  defp camelize(val) when is_integer(val) or is_float(val),
    do: val
  defp camelize(<<?_, t::binary>>),
    do: camelize(t)
  defp camelize(<<h, t::binary>>),
    do: <<to_lower_char(h)>> <> do_camelize(t)

  defp do_camelize(<<?_, ?_, t::binary>>),
    do: do_camelize(<<?_, t::binary >>)
  defp do_camelize(<<?_, h, t::binary>>) when h >= ?a and h <= ?z,
    do: <<to_upper_char(h)>> <> do_camelize(t)
  defp do_camelize(<<?_, h, t::binary>>) when h >= ?0 and h <= ?9,
    do: <<h>> <> do_camelize(t)
  defp do_camelize(<<?_>>),
    do: <<>>
  defp do_camelize(<<?/, t::binary>>),
    do: <<?.>> <> camelize(t)
  defp do_camelize(<<h, t::binary>>),
    do: <<h>> <> do_camelize(t)
  defp do_camelize(<<>>),
    do: <<>>

  defp to_upper_char(char) when char >= ?a and char <= ?z, do: char - 32
  defp to_upper_char(char), do: char

  defp to_lower_char(char) when char >= ?A and char <= ?Z, do: char + 32
  defp to_lower_char(char), do: char

end
