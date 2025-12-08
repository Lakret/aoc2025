#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <day>" >&2
    echo "Example: $0 d01" >&2
    exit 1
fi

day=$1

start_time=$(date +%s.%N 2>/dev/null || date +%s)

if [ -f "${day}/Cargo.toml" ]; then
    (cd "${day}" && cargo run --release)
elif [ -f "${day}.py" ]; then
    python "${day}.py"
elif [ -f "${day}.jl" ]; then
    julia "${day}.jl"
else
    echo "Error: File ${day}.py, ${day}.jl, or directory ${day}/ with Cargo.toml not found" >&2
    exit 1
fi

end_time=$(date +%s.%N 2>/dev/null || date +%s)
elapsed=$(awk "BEGIN {printf \"%.3f\", $end_time - $start_time}")
echo "Runtime: ${elapsed}s"
