using Pipe

parse_input(input::AbstractString) = @pipe input |> chomp |> split .|> split(_, ",") .|> parse.(Int, _)

area(a::Vector{Int}, b::Vector{Int})::Int = (a .- b) .|> abs .|> (x -> x + 1) |> prod

p1(input::Vector{Vector{Int}})::Int =
  [area(input[idx1], input[idx2]) for idx1 in eachindex(input) for idx2 in eachindex(input) if idx1 < idx2] |> maximum


@assert area([2, 5], [9, 7]) == 24
@assert area([7, 1], [11, 7]) == 35
@assert area([7, 3], [2, 3]) == 6
@assert area([2, 5], [11, 1]) == 50

test_input = """
             7,1
             11,1
             11,7
             9,7
             9,5
             2,5
             2,3
             7,3
             """ |> parse_input

input = read("inputs/d09.txt", String) |> parse_input

@assert p1(test_input) == 50
@assert @show @time p1(input) == 4758121828
