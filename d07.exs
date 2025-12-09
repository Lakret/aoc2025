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

  # TODO: beams should be a map %{{row, col} => timelines} instead of a MapSet
  @doc false
  def split(splitters, beams) do
    if MapSet.size(splitters) == 0 do
      beams
      |> Enum.map(fn {row, col} -> {row + 1, col} end)
      |> MapSet.new()
    else
      Enum.reduce(beams, MapSet.new(), fn {row, col}, beams ->
        row = row + 1

        if {row, col} in splitters do
          beams
          |> MapSet.put({row, col - 1})
          |> MapSet.put({row, col + 1})
        else
          beams
          |> MapSet.put({row, col})
        end
      end)
    end
  end

  def p1(%__MODULE__{} = manifold) do
    Enum.reduce(manifold.splitters, {MapSet.new([manifold.start_pos]), 0}, fn splitters,
                                                                              {beams, n_splits} ->
      new_splits =
        beams
        |> Enum.map(fn {row, col} -> {row + 1, col} end)
        |> MapSet.new()
        |> MapSet.intersection(splitters)
        |> MapSet.size()

      beams = split(splitters, beams)
      {beams, n_splits + new_splits}
    end)
  end

  #   def p2(%__MODULE__{} = manifold) do
  #     {_, timelines} =
  #       Enum.reduce(
  #         manifold.splitters,
  #         {MapSet.new([manifold.start_pos]), %{manifold.start_pos => 1}},
  #         fn splitters, {beams, timelines} ->
  #           split(splitters, beams, timelines)
  #         end
  #       )

  #     timelines
  #   end
end

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
{test_beams, test_n_splits} = Manifold.p1(test_manifold)
9 = MapSet.size(test_beams)
21 = test_n_splits

input = File.read!("inputs/d07.txt")
manifold = Manifold.parse(input)
{beams, n_splits} = Manifold.p1(manifold)
1543 = n_splits

# 40 = Manifold.p2(test_manifold)

# 3130 is too low
# Manifold.p2(manifold)
