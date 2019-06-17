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
      assert Deep.merge([a: [b: [1, 2, 3]], f: 5], [a: [b: [4, 5, 6]]]) == [a: [b: [3, 6, 2, 5, 1, 4]], f: 5]
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

    test "Shallow merge" do
      first_merge = Deep.merge([a: [%{a: 1}, %{a: 2}, %{a: 3}], f: 5], [a: [%{a: 3}, %{a: 1}, %{a: 2}]])
      assert first_merge == [a: [%{a: 3}, %{a: 2}, %{a: 1}], f: 5]
      assert Deep.merge(first_merge, [a: [%{a: 2}, %{b: 3}, %{a: 1}]]) == [a: [%{a: 3}, %{b: 3}, %{a: 2}, %{a: 1}], f: 5]

      first_merge = Deep.merge([a: [1, 2, %{a: "b"}], f: 5], [a: [2, %{a: "b"}, 1]])
      assert first_merge == [a: [%{a: "b"}, 2, 1], f: 5]
      assert Deep.merge([a: [%{a: "b"}, 8, 6]], first_merge) == [a: [%{a: "b"}, 8, 2, 6, 1], f: 5]
      assert Deep.merge(first_merge, [a: [1, 5, 3]]) ==  [a: [%{a: "b"}, 5, 2, 3, 1], f: 5]
    end
  end
end
