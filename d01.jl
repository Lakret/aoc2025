function parse_input(input)
    map(input) do line
        v = parse(Int, line[2:end])
        line[1] == 'R' ? v : -v
    end
end

rotate(pos::Int, move::Int) = mod(pos + move, 100)

function p1(moves::Vector{Int})::Int
    pos, cnt = 50, 0

    for move in moves
        pos = rotate(pos, move)

        if pos == 0
            cnt += 1
        end
    end

    cnt
end

function p2(moves::Vector{Int})::Int
    pos, cnt = 50, 0

    for move in moves
        new_pos = rotate(pos, move)

        # if we are at zero or we ended up being in the same position or lower / higher position when moving to the right / left,
        # we know that we crossed zero on the way
        if new_pos == 0 || (move > 0 && new_pos <= pos && pos != 0) || (move < 0 && new_pos >= pos && pos != 0)
            cnt += 1
        end

        # if the move is larger than one rotation, account for the remaining rotations
        cnt += fld(abs(move), 100)

        pos = new_pos
    end

    cnt
end


input = readlines("inputs/d01.txt") |> parse_input
test_input = """
             L68
             L30
             R48
             L5
             R60
             L55
             L1
             L99
             R14
             L82
             """ |> chomp |> split |> parse_input

@assert p1(test_input) == 3
@assert @show @time p1(input) == 1031

@assert p2(test_input) == 6
@assert @show @time p2(input) == 5831
