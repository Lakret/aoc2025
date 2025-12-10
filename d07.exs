defmodule Manifold do
  defstruct [:width, :start_pos, :splitters]

  def parse(input) do
    [start | manifold] = input |> String.trim() |> String.split("\n")
    width = String.length(start)
    start_col = start |> String.graphemes() |> Enum.find_index(&(&1 == "S"))
    start_pos = {0, start_col}

    splitters =
      manifold
      |> Enum.with_index()
      |> Enum.map(fn {line, row} ->
        # the first row we see is the row at index one, since we split the start row
        row = row + 1

        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(MapSet.new(), fn {ch, col}, splitters ->
          case ch do
            "." -> splitters
            "^" -> MapSet.put(splitters, {row, col})
          end
        end)
      end)

    %__MODULE__{width: width, start_pos: start_pos, splitters: splitters}
  end

  @doc false
  def split(%MapSet{} = splitters, row_idx, beams) when is_map(beams) do
    if MapSet.size(splitters) == 0 do
      next_level =
        beams
        |> Enum.filter(fn {{row, _}, _} -> row == row_idx end)
        |> Enum.map(fn {{row, col}, timelines} -> {{row + 1, col}, timelines} end)
        |> Map.new()

      Map.merge(beams, next_level)
    else
      current_beams = beams |> Enum.filter(fn {{row, _}, _} -> row == row_idx end)
      Enum.reduce(current_beams, beams, fn {{row, col}, timelines}, beams ->
        next_row = row + 1

        if {next_row, col} in splitters do
          beams
          |> Map.update({next_row, col - 1}, timelines, &(&1 + timelines))
          |> Map.update({next_row, col + 1}, timelines, &(&1 + timelines))
        else
          Map.update(beams, {next_row, col}, timelines, &(&1 + timelines))
        end
      end)
    end
  end

  def p1(%__MODULE__{} = manifold) do
    manifold.splitters
    |> Enum.with_index()
    |> Enum.reduce({%{manifold.start_pos => 1}, 0}, fn {splitters, row_idx}, {beams, n_splits} ->
      new_splits =
        beams
        |> Map.keys()
        |> Enum.map(fn {row, col} -> {row + 1, col} end)
        |> MapSet.new()
        |> MapSet.intersection(splitters)
        |> MapSet.size()

      beams = split(splitters, row_idx, beams)
      {beams, n_splits + new_splits}
    end)
  end

    def p2(%__MODULE__{} = manifold) do

            manifold.splitters
            |> Enum.with_index()
            |> Enum.reduce(%{manifold.start_pos => 1}, fn {splitters, row_idx}, beams->
                split(splitters, row_idx, beams)
            end)
|> Enum.filter(fn {{row, _}, _} -> row == length(manifold.splitters) end)
        |> Enum.map(fn {_, timelines} -> timelines end)
        |> Enum.sum()
    end
end

import ExUnit.Assertions

test_input =
  """
  .......S.......
  ...............
  .......^.......
  ...............
  ......^.^......
  ...............
  .....^.^.^.....
  ...............
  ....^.^...^....
  ...............
  ...^.^...^.^...
  ...............
  ..^...^.....^..
  ...............
  .^.^.^.^.^...^.
  ...............
  """

test_manifold = Manifold.parse(test_input)
input = File.read!("inputs/d07.txt")
manifold = Manifold.parse(input)

{_test_beams, test_n_splits} = Manifold.p1(test_manifold)
assert test_n_splits == 21
{_beams, n_splits} = Manifold.p1(manifold)
assert n_splits |> IO.inspect(label: :p1) == 1543

assert Manifold.p2(test_manifold) == 40
assert Manifold.p2(manifold) |> IO.inspect(label: :p2) == 3223365367809
