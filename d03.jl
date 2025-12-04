using Pipe

parse_input(input) = @pipe input |> chomp |> split .|> collect .|> parse.(Int, _) # |> mapreduce(permutedims, vcat, _)


function max_joltage(bank::Vector{Int}, max_batteries::Int=2)::Int
    left_bound, result = 1, 0

    for battery_id in max_batteries:-1:1
        start_from = battery_id == max_batteries ? left_bound : left_bound + 1
        available_bank = bank[start_from:end-(battery_id-1)]

        selected_battery = argmax(available_bank)
        result += available_bank[selected_battery] * 10^(battery_id - 1)
        left_bound = selected_battery + (start_from - 1)
    end

    result
end

p1(input) = input .|> max_joltage |> sum
p2(input) = @pipe input .|> max_joltage(_, 12) |> sum


input = read("inputs/d03.txt", String) |> parse_input
test_input = parse_input("""
987654321111111
811111111111119
234234234234278
818181911112111
""")

@assert p1(test_input) == 357
@assert @show @time p1(input) == 17694

@assert p2(test_input) == 3121910778619
@assert @show @time p2(input) == 175659236361660
