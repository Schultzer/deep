base_map = (0..50)
|> Enum.zip(300..350)
|> Enum.into(%{})

orig = Map.merge base_map, %{150 => %{1 => 1, 2 => 2}, 155 => %{y: :x}, 170 => %{"foo" => "bar"}, z: %{ x: 4, y: %{a: 1, b: %{c: 2}, d: %{"hey" => "ho"}}}, a: %{b: %{c: %{a: 99, d: "foo", e: 2}}, m: [33], i: 99, y: "bar"}, b: %{y: [23, 87]}, z: %{xy: %{y: :x}}}
new = Map.merge base_map, %{150 => %{3 => 3}, 160 => %{a: "b"}, z: %{ xui: [44], y: %{b: %{c: 77, d: 55}, d: %{"ho" => "hey", "du" => "nu", "hey" => "ha"}}}, a: %{b: %{c: %{a: 1, b: 2, d: "bar"}}, m: 12, i: 102}, b: %{ x: 65, y: [23]}, z: %{ xy: %{x: :y}}}

Benchee.run(%{
  "Map.merge/3 simple" => fn -> Map.merge(orig, new, fn(_key, _base, override) -> override end) end,
  "Map.merge/3 complex" => fn -> Map.merge(orig, new,
  fn
    _key, same, same                                               -> same
    _key, base, override when is_map(base) and is_map(override)    -> Map.merge(base, override)
    _key, [{_, _} |_] = base, [{_, _} |_] = override               -> Keyword.merge(base, override)
    _key, base, override when is_list(base) and is_list(base)      -> base ++ override
    _key, base, override                                           -> override
  end)
    end,
  "DeepMerge.deep_merge/2" => fn -> DeepMerge.deep_merge(orig, new) end,
  "Deep.merge/2"           => fn -> Deep.merge(orig, new) end,
  "Deep.merge2/2"          => fn -> Deep.merge2(orig, new) end,
  "Deep.merge3/2"          => fn -> Deep.merge3(orig, new) end,
}, time: 10, memory_time: 2)
