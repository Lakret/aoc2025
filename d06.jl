"""
Here the problem is inverted: instead of different solutions, we just need to implement different
parsing for parts 1 and 2.

Thanks to Julia's array operations, parsing for part 2 is rather simple, we just build a matrix and iterate
it column by column from right to left (`eachcol |> reverse`), before collecting it into the arrays.
"""

using Pipe

function parse_op(op::AbstractString)::Function
    if op == "+"
        (+)
    elseif op == "*"
        (*)
    else
        error("Invalid operator: $op")
    end
end

struct Problem
    nums::Vector{BigInt}
    op::Function
end

function parse_input(input)
    lines = @pipe input |> strip |> split(_, '\n') |> strip.(_)
    nums = @pipe lines[1:end-1] .|> split .|> parse.(BigInt, _) |> reduce(hcat, _)
    ops = @pipe lines[end] .|> split .|> parse_op.(_)


    [Problem(n, ops[idx]) for (idx, n) in enumerate(eachrow(nums))]
end

function parse_input2(input)
    cols = @pipe input |> strip(_, '\n') |> split(_, '\n') |> collect.(_) |> mapreduce(permutedims, vcat, _) |> eachcol |> reverse |> collect

    problems, nums = Problem[], []
    for col in cols
        num, op = "", missing

        for ch in col
            if isdigit(ch)
                num *= ch
            elseif ch ∈ ['+', '*']
                op = ch |> string |> parse_op
                push!(nums, parse(BigInt, num))

                push!(problems, Problem(nums, op))
                num, op = "", missing
                nums = []
            end
        end

        if num != ""
            push!(nums, parse(BigInt, num))
            num = ""
        end
    end
    problems
end

function solve(problems::Vector{Problem})::BigInt
    res = big(0)
    for problem in problems
        res += @pipe problem.nums |> reduce(problem.op, _)
    end
    res
end

p1 = solve ∘ parse_input
p2 = solve ∘ parse_input2

test_input = "
123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  
"
input = read("inputs/d06.txt", String)

@assert p1(test_input) == 4277556
@assert @show @time p1(input) == 6209956042374

@assert p2(test_input) == 3263827
@assert @show @time p2(input) == 12608160008022
