///! The core of the solution is using the built-in `std::ops::RangeInclusive` struct.
///! Part 1 is trivial, for part 2 we need to adjust ranges depending on their overlap
///! with other ranges. To simplify this, we replace Vec<RangeInclusive<_>> with Vec<Option<RangeInclusive<_>>>,
///! and then in case a range is fully contained in another range, we replace it with None;
///! in case another range contains the start of the current range, we adjust the start of the current range to be
///! after the end of that other range; and in case the end of the current range is contained in another range,
///! we adjust the end of the current range to be before the start of that other range.
use std::fs::File;
use std::io;
use std::ops::RangeInclusive;

#[derive(Debug)]
struct Inventory {
    freshness: Vec<RangeInclusive<u64>>,
    ids: Vec<u64>,
}

fn parse_input(input: &str) -> Inventory {
    let mut lines = input.trim().split("\n");

    let mut freshness = vec![];
    for line in &mut lines {
        if line == "" {
            break;
        }

        let range = line
            .split("-")
            .map(|s| s.parse::<u64>().unwrap())
            .collect::<Vec<_>>();
        freshness.push(range[0]..=range[1]);
    }

    let mut ids = vec![];
    for line in &mut lines {
        ids.push(line.parse::<u64>().unwrap());
    }

    Inventory { freshness, ids }
}

fn p1(inventory: &Inventory) -> usize {
    inventory
        .ids
        .iter()
        .filter(|id| inventory.freshness.iter().any(|range| range.contains(id)))
        .count()
}

fn p2(inventory: &Inventory) -> usize {
    let mut freshness = inventory
        .freshness
        .clone()
        .into_iter()
        .map(|x| Some(x))
        .collect::<Vec<_>>();

    for idx in 0..freshness.len() {
        for another_idx in 0..freshness.len() {
            if another_idx != idx
                && let Some(another_range) = &freshness[another_idx]
                && let Some(current_range) = &freshness[idx]
            {
                if another_range.contains(current_range.start())
                    && another_range.contains(current_range.end())
                {
                    freshness[idx] = None;
                } else if another_range.contains(current_range.start()) {
                    let new_range = (*another_range.end() + 1)..=*current_range.end();
                    freshness[idx] = Some(new_range);
                } else if another_range.contains(current_range.end()) {
                    let new_range = (*current_range.start())..=*another_range.start() - 1;
                    freshness[idx] = Some(new_range);
                }
            }
        }
    }

    freshness
        .into_iter()
        .filter(|range| range.is_some())
        .map(|range| {
            let range = range.unwrap();
            (range.end() - range.start() + 1) as usize
        })
        .sum()
}

fn main() {
    let inventory = input();

    let p1_ans = p1(&inventory);
    println!("p1: {p1_ans:?}");

    let p2_ans = p2(&inventory);
    println!("p2: {p2_ans:?}");
}

fn input() -> Inventory {
    let file = File::open("../inputs/d05.txt").unwrap();
    let contents = io::read_to_string(file).unwrap();
    parse_input(&contents)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_input() -> Inventory {
        parse_input(
            "
3-5
10-14
16-20
12-18

1
5
8
11
17
32
",
        )
    }

    #[test]
    fn test_p1() {
        let inventory = test_input();
        assert_eq!(p1(&inventory), 3);

        let inventory = input();
        assert_eq!(p1(&inventory), 865);
    }

    #[test]
    fn test_p2() {
        let inventory = test_input();
        assert_eq!(p2(&inventory), 14);

        // let inventory = input();
        // assert_eq!(p2(&inventory), 1000);
    }
}
