# Deep

Blazing fast and zero overhead merging of deep `map() | struct() | keyword()`.

implementet with a "right is right" algorithm

## Examples

```elixir
iex> Deep.merge(%{a: 1, b: [x: 10, y: 9]}, %{b: [y: 20, z: 30], c: 4})
%{a: 1, b: [x: 10, y: 20, z: 30], c: 4}

iex> Deep.merge(1..6, 12..6)
1..12

iex> Deep.merge(Stream.map(1..3, &IO.inspect/1), Stream.map([4, 5], &IO.inspect/1))
#Stream<[enum: [4, 5], funs: [#Function<48.51129937/1 in Stream.map/2>]]>
```

## Benchmarks
```
Operating System: macOS"
CPU Information: Intel(R) Core(TM) i7-4578U CPU @ 3.00GHz
Number of Available Cores: 4
Available memory: 16 GB
Elixir 1.7.1
Erlang 21.0.4

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 42 s


Benchmarking Deep.merge/2...
Benchmarking DeepMerge.deep_merge/2...
Benchmarking Map.merge/3...

Name                             ips        average  deviation         median         99th %
Deep.merge/2                 12.85 K       77.84 μs   ±176.05%          66 μs         196 μs
Map.merge/3                   8.02 K      124.70 μs    ±16.67%         118 μs         222 μs
DeepMerge.deep_merge/2        5.06 K      197.50 μs    ±43.25%         181 μs         413 μs

Comparison:
Deep.merge/2                 12.85 K
Map.merge/3                   8.02 K - 1.60x slower
DeepMerge.deep_merge/2        5.06 K - 2.54x slower

Memory usage statistics:

Name                           average  deviation         median         99th %
Deep.merge/2                 153.09 KB     ±7.13%      154.33 KB      154.33 KB
Map.merge/3                  183.49 KB     ±2.89%      183.69 KB      183.69 KB
DeepMerge.deep_merge/2       226.15 KB     ±2.33%      226.45 KB      226.45 KB

Comparison:
Deep.merge/2                 154.33 KB
Map.merge/3                  183.69 KB - 1.19x memory usage
DeepMerge.deep_merge/2       226.45 KB - 1.47x memory usage
```

## Documentation

[hex documentation for deep](https://hexdocs.pm/deep/)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `deep` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:deep, "~> 0.1.0"}
  ]
end
```

## LICENSE

(The MIT License)

Copyright (c) 2018 Benjamin Schultzer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
