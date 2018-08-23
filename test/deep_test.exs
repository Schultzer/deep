defmodule DeepTest do
  use ExUnit.Case
  doctest Deep

  defmodule Left do
    defstruct [:attrs]
  end

  defmodule Right do
    defstruct [:attrs]
  end

  describe "merge/2" do
    test "Keyword" do
      assert Deep.merge([a: [b: []], f: 5], [a: [b: [c: 2]]])           == [a: [b: [c: 2]], f: 5]
      assert Deep.merge([a: [b: [c: 2]], f: 5], [a: [b: []]])           == [a: [b: [c: 2]], f: 5]
      assert Deep.merge([a: [b: [c: 2]], f: 5], [a: [b: [1, 2, 3]]])    == [a: [b: [1, 2, 3]], f: 5]
      assert Deep.merge([a: [b: [1, 2, 3]], f: 5], [a: [b: [c: 2]]])    == [a: [b: [c: 2]], f: 5]
      assert Deep.merge([a: [b: []], f: 5], [a: [b: []]])               == [a: [b: []], f: 5]
      assert Deep.merge([a: [b: [1, 2, 3]], f: 5], [a: [b: [4, 5, 6]]]) == [a: [b: [1, 2, 3, 4, 5, 6]], f: 5]
    end

    test "Map" do
      assert Deep.merge(%{attrs: [a: [a: 1, b: 2]]}, %{attrs: [a: [c: 3], d: 4]}) == %{attrs: [a: [a: 1, b: 2, c: 3], d: 4]}
      assert Deep.merge(%{attrs: %{a: %{a: 1, b: 2}}}, %{attrs: %{a: %{c: 3}}, d: 4}) == %{attrs: %{a: %{a: 1, b: 2, c: 3}}, d: 4}
      assert Deep.merge(%{attrs: %{a: %{a: 1, b: 2}}}, %{attrs: %{a: [c: 3]}, d: 4}) == %{attrs: %{a: [a: 1, b: 2, c: 3]}, d: 4}
      assert Deep.merge(%{attrs: %{a: [a: 1, b: 2]}}, %{attrs: %{a: %{c: 3}}, d: 4}) == %{attrs: %{a: %{a: 1, b: 2, c: 3}}, d: 4}
    end

    test "Struct" do
      assert Deep.merge(%Left{attrs: [a: [a: 1, b: 2]]}, %Left{attrs: [a: [c: 3], d: 4]}) == %Left{attrs: [a: [a: 1, b: 2, c: 3], d: 4]}
      assert Deep.merge(%Left{attrs: %{a: %{a: 1, b: 2}}}, %Left{attrs: %{a: %{c: 3}, d: 4}}) == %Left{attrs: %{a: %{a: 1, b: 2, c: 3}, d: 4}}
      assert Deep.merge(%Left{attrs: %{a: %{a: 1, b: 2}}}, %Left{attrs: %{a: [c: 3], d: 4}}) == %Left{attrs: %{a: [a: 1, b: 2, c: 3], d: 4}}

      assert_raise ArgumentError, "Can't merge %Elixir.DeepTest.Left{} into %Elixir.DeepTest.Right{}", fn ->
        Deep.merge(%Left{attrs: [a: 1]}, %Right{attrs: [a: 2]})
      end
      assert_raise ArgumentError, "Can't merge %{} into %Elixir.DeepTest.Right{}", fn ->
        Deep.merge(%{}, %Right{attrs: [a: 2]})
      end
      assert_raise ArgumentError, "Can't merge %Elixir.DeepTest.Left{} into %{}", fn ->
        Deep.merge(%Left{attrs: [a: 1]}, %{})
      end
      assert_raise ArgumentError, "Can't merge [] into %Elixir.DeepTest.Right{}", fn ->
        Deep.merge([], %Right{attrs: [a: 2]})
      end
      assert_raise ArgumentError, "Can't merge %Elixir.DeepTest.Left{} into []", fn ->
        Deep.merge(%Left{attrs: [a: 1]}, [])
      end
    end
  end
end
