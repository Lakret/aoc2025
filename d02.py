from math import log10, ceil


def parse_input(input: str) -> list[range]:
    return [
        range(int(bounds[0]), (int(bounds[1]) + 1)) for bounds in [rng.split("-") for rng in input.strip().split(",")]
    ]


def is_repetition(n: int, num_length: int, pattern_length: int) -> bool:
    power = num_length - pattern_length
    pattern = str(int(n // 10**power))
    return int(pattern * int(num_length // pattern_length)) == n


def is_invalid_p1(n: int) -> bool:
    num_length = ceil(log10(n))
    # non-even length numbers cannot be invalid
    if num_length == 0 or num_length % 2 != 0:
        return False

    # pattern length is always known since it should be half of the number length
    pattern_length = int(num_length // 2)
    return is_repetition(n, num_length, pattern_length)


def is_invalid_p2(n: int) -> bool:
    num_length = ceil(log10(n))
    if num_length == 0:
        return False

    # we cannot repeat a pattern less than 2 times
    max_pattern_length = int(num_length // 2)

    for pattern_length in range(1, max_pattern_length + 1):
        if is_repetition(n, num_length, pattern_length):
            return True
    return False


def p1(input: list[range]) -> int:
    return sum([n for rng in input for n in rng if is_invalid_p1(n)])


def p2(input: list[range]) -> int:
    return sum([n for rng in input for n in rng if is_invalid_p2(n)])


if __name__ == "__main__":
    test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
    test_input = parse_input(test_input)

    with open("inputs/d02.txt") as f:
        input = parse_input(f.read())

    assert p1(test_input) == 1227775554
    print(f"p1: {p1(input)}")

    assert p2(test_input) == 4174379265
    print(f"p2: {p2(input)}")
