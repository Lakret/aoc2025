using Pipe

parse_input(input) = @pipe input |> chomp |> split .|> collect .|> map(ch -> ch == '.' ? 0 : 1, _) |> mapreduce(permutedims, vcat, _)

neighbours = [(x, y) for x in -1:1, y in -1:1 if x != 0 || y != 0]

is_accessible(grid::Matrix{Int}, x::Int, y::Int) = sum(
    grid[x+dx, y+dy]
    for (dx, dy) in neighbours
    if x + dx >= 1 && x + dx <= size(grid, 1) && y + dy >= 1 && y + dy <= size(grid, 2)
) < 4

p1(grid::Matrix{Int}) = sum(grid[x, y] == 1 && is_accessible(grid, x, y) for x in 1:size(grid, 1), y in 1:size(grid, 2))

function p2(grid::Matrix{Int})
    grid, removed = deepcopy(grid), 0

    while true
        to_remove = [(x, y) for x in 1:size(grid, 1), y in 1:size(grid, 2) if grid[x, y] == 1 && is_accessible(grid, x, y)]
        if isempty(to_remove)
            return removed
        end

        removed += length(to_remove)
        for (x, y) in to_remove
            grid[x, y] = 0
        end
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
