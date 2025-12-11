"""
As is often the case with "game of life" like tasks, Julia's CartesianIndex is the goat.
Since we are working with truthiness, we can also use BitMatrix.

And then, `checkbounds` and comprehensions are used for implementing `is_accessible` check,
while `findall` (returns all CartesianIndices of true elements), 
[logical indexing](https://docs.julialang.org/en/v1/manual/arrays/#Logical-indexing),
[broadcast assign](https://docs.julialang.org/en/v1/manual/mathematical-operations/#man-dot-operators)
make part 2 a breeze.
"""
using Pipe

parse_input(input)::BitMatrix = @pipe input |> chomp |> split .|> collect .|> map(ch -> ch == '.' ? false : true, _) |> mapreduce(permutedims, vcat, _) |> BitMatrix

neighbours = [CartesianIndex(x, y) for x in -1:1, y in -1:1 if x != 0 || y != 0]

is_accessible(grid::BitMatrix, idx::CartesianIndex) =
    grid[idx] && sum(grid[idx+delta] for delta in neighbours if checkbounds(Bool, grid, idx + delta)) < 4

# placing grid into a single element tuple "protects" it from broadcast
p1(grid::BitMatrix) = sum(is_accessible.((grid,), findall(grid)))

function p2(grid::BitMatrix)
    grid, removed = deepcopy(grid), 0
    all_indices = findall(grid)

    while true
        to_remove = all_indices[is_accessible.((grid,), all_indices)]
        if isempty(to_remove)
            return removed
        end

        removed += length(to_remove)
        grid[CartesianIndex.(to_remove)] .= 0
    end
end

test_input = """
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
""" |> parse_input

input = read("inputs/d04.txt", String) |> parse_input

@assert p1(test_input) == 13
@assert @show @time p1(input) == 1502

@assert p2(test_input) == 43
@assert @show @time p2(input) == 9083
