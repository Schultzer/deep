defmodule Deep do
  @moduledoc """
  Blazing fast and zero overhead merging of deep `map() | struct() | keyword()`.
  """

  @doc """
  Merge `map() | keyword() | struct()`.

  ## Examples

      iex> Deep.merge(%{a: 1, b: [x: 10, y: 9]}, %{b: [y: 20, z: 30], c: 4})
      %{a: 1, b: [x: 10, y: 20, z: 30], c: 4}

  """
  @spec merge(map() | keyword(), map() | keyword()) :: map() | keyword() | no_return()
  def merge(same, same), do: same
  def merge(%Range{first: f1, last: l1}, %Range{first: f2, last: l2}) do
    [first, _, _, last] = Enum.sort([f1, l1, f2, l2])
    %Range{first: first, last: last}
  end
  def merge(%{__struct__: left}, %{__struct__: right}) when left !== right, do: raise ArgumentError, "Can't merge %#{left}{} into %#{right}{}"
  def merge(%{__struct__: _} = left, %{__struct__: _} = right) do
    left
    |> :maps.to_list()
    |> deep_merge(:maps.to_list(right))
  end
  def merge(%{__struct__: left}, right) when is_map(right) or is_list(right), do: raise ArgumentError, "Can't merge %#{left}{} into #{inspect right}"
  def merge(left, %{__struct__: right}) when is_map(left) or is_list(left), do: raise ArgumentError, "Can't merge #{inspect left} into %#{right}{}"
  def merge(left, right) when is_map(left) and is_map(right) do
    left
    |> :maps.to_list()
    |> deep_merge(:maps.to_list(right))
  end
  def merge(left, [{_, _} | _] = right) when is_map(left)  do
    left
    |> :maps.to_list()
    |> deep_merge(right)
    |> :maps.to_list()
  end
  def merge([{_, _} | _] = left, right) when is_map(right)  do
    deep_merge(left, :maps.to_list(right))
  end
  def merge([{_, _} | _] = left, [{_, _} | _] = right) do
    left
    |> deep_merge(right)
    |> :maps.to_list()
  end

  ####################################################################################################
  def merge2(left, right) when is_map(left) and is_map(right) do                                     #
    left
    |> :maps.iterator()
    |> :maps.next()
    |> deep_merge2(right)
  end
  def merge2([{_, _} | _] = left, right) when is_map(right) do
    deep_merge2(left, right)
  end
  def merge2([{_, _} | _] = left, [{_, _} | _] = right) do
    left
    |> deep_merge(right)
    |> :maps.to_list()
  end

  defp deep_merge2(:none, right),                 do: right
  defp deep_merge2([], right),                    do: right
  defp deep_merge2({key, value, next}, right),    do: deep_merge2(:maps.next(next), update(right, key, value))
  defp deep_merge2([{key, value} | next], right), do: deep_merge2(next, update(right, key, value))
  ####################################################################################################
  ####################################################################################################
  def merge3(left, right) when is_map(left) and is_map(right) do                                     #
  left
  |> :maps.iterator()
  |> :maps.next()
  |> deep_merge3(right)
  end
  def merge3([{_, _} | _] = left, right) when is_map(right), do: deep_merge3(left, right)
  def merge3([{_, _} | _] = left, [{_, _} | _] = right) do
    left
    |> deep_merge3(right)
    |> :maps.to_list()
  end

  defp deep_merge3(:none, right), do: right
  defp deep_merge3([], right), do: right
  defp deep_merge3({key, value, next}, right) do
    deep_merge3(:maps.next(next), update(right, key, value))
  end
  defp deep_merge3([{key, value} | next], [{key, value} | _] = right) do
    deep_merge3(next, right)
  end
  defp deep_merge3([{key, value} | next], right) do
    deep_merge3(next, update(right, key, value))
  end
####################################################################################################


  defp deep_merge(left, right, acc \\ %{})
  defp deep_merge([], [], acc), do: acc
  defp deep_merge([{key, value} | left], [] = right, acc), do: deep_merge(left, right, update(acc, key, value))
  defp deep_merge([] = left, [{key, value} | right], acc), do: deep_merge(left, right, update(acc, key, value))
  defp deep_merge([{key, value} | left], [{key, value} | right], acc) do
    deep_merge(left, right, :maps.put(key, value, acc))
  end
  defp deep_merge([{key, [{_, _} | _] = l} | left], [{key, [{_, _} | _] = r} | right], acc) do
    deep_merge(left, right, :maps.put(key, merge(l, r), acc))
  end
  defp deep_merge([{key, l} | left], [{key, r} | right], acc) do
    deep_merge(left, right, :maps.put(key, merge_value(l, r), acc))
  end
  defp deep_merge([{k1, v1} | left], [{k2, v2} | right], acc) do
    deep_merge(left, right, acc |> update(k1, v1) |> update(k2, v2))
  end

  defp merge_value(same, same), do: same
  defp merge_value(%Range{first: f1, last: l1}, %Range{first: f2, last: l2}) do
    [first, _, _, last] = Enum.sort([f1, l1, f2, l2])
    %Range{first: first, last: last}
  end
  defp merge_value(left, right)                when is_map(left) and is_map(right), do: merge(left, right)
  defp merge_value(left, [{_, _} | _] = right) when is_map(left),                   do: merge(left, right)
  defp merge_value([{_, _} | _] = left, right) when is_map(right),                  do: merge(left, right)
  defp merge_value([{_, _} | _] = left, [{_, _} | _] = right),                      do: merge(left, right)
  defp merge_value([{_, _} | _] = left, []),                                        do: left
  defp merge_value(_left, [{_, _} | _] = right),                                    do: right
  defp merge_value([{_, _} | _], right),                                            do: right
  defp merge_value(left, right) when is_list(left) and is_list(right),              do: shallow_merge(left, right)
  defp merge_value(_left, right),                                                   do: right

  defp update([{_, _} | _] = acc, key, value), do: Keyword.update(acc, key, value, &merge_value(value, &1))
  defp update(acc, key, value),                do: Map.update(acc, key, value, &merge_value(value, &1))

  defp shallow_merge(left, right) do
    shallow_merge(Enum.sort(left), Enum.sort(right), [])
  end

  defp shallow_merge([], [], acc), do: acc
  defp shallow_merge([same | left], [] = right, [same | _] = acc) do
    shallow_merge(left, right, acc)
  end
  defp shallow_merge([] = left, [same | right], [same | _] = acc) do
    shallow_merge(left, right, acc)
  end
  defp shallow_merge([l | left], [] = right, acc) do
    case l in acc do
      true  -> shallow_merge(left, right, acc)

      false -> shallow_merge(left, right, [l | acc])
    end
  end
  defp shallow_merge([] = left, [r | right], acc) do
    case r in acc do
      true  -> shallow_merge(left, right, acc)

      false -> shallow_merge(left, right, [r | acc])
    end
  end
  defp shallow_merge([same | left], [same | right], [same | _] = acc) do
    shallow_merge(left, right, acc)
  end
  defp shallow_merge([l | left], [same | right], [same | _] = acc) do
    shallow_merge(left, right, [l | acc])
  end
  defp shallow_merge([same | left], [r | right], [same | _] = acc) do
    shallow_merge(left, right, [r | acc])
  end

  defp shallow_merge([same | left], [same | right], acc) do
    shallow_merge(left, right, [same | acc])
  end
  defp shallow_merge([l | left], [r | right], acc) do
    shallow_merge(left, right, [l, r | acc])
  end
end
