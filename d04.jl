using Pipe

parse_input(input)::Matrix{Bool} = @pipe input |> chomp |> split .|> collect .|> map(ch -> ch == '.' ? false : true, _) |> mapreduce(permutedims, vcat, _)

neighbours = [CartesianIndex(x, y) for x in -1:1, y in -1:1 if x != 0 || y != 0]

is_accessible(grid::Matrix{Bool}, idx::CartesianIndex) =
    grid[idx] && sum(grid[idx+delta] for delta in neighbours if checkbounds(Bool, grid, idx + delta)) < 4

p1(grid::Matrix{Bool}) = sum(is_accessible.((grid,), findall(grid)))

function p2(grid::Matrix{Bool})
    grid, removed = deepcopy(grid), 0
    all_indices = findall(grid)

    while true
        # placing grid into a single element tuple "protects" it from broadcast
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
