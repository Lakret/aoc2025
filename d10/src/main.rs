use regex::Regex;
use std::collections::{HashMap, HashSet};
use std::fs;
use std::sync::LazyLock;

type Button = HashSet<u8>;

#[derive(Debug, Clone)]
struct Machine {
    nlights: u8,
    target_lights: HashSet<u8>,
    buttons: Vec<Button>,
    joltages: Vec<u32>,
}

impl Machine {
    // Implemented by doing a breadth-first search on a tree of states.
    fn min_presses(&self) -> usize {
        let mut states: Vec<HashSet<u8>> = vec![HashSet::new()];
        let mut new_states = vec![];
        let mut level = 1;

        loop {
            for state in &states {
                for button in &self.buttons {
                    let new_state = press(state, button);

                    if new_state == self.target_lights {
                        return level;
                    }

                    new_states.push(new_state);
                }
            }

            states = new_states;
            new_states = vec![];
            level += 1;
        }
    }
}

fn press(state: &HashSet<u8>, button: &HashSet<u8>) -> HashSet<u8> {
    state.symmetric_difference(button).copied().collect()
}

static MACHINE_SPEC: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(
        r"\[(?<target_lights>[.#]+)\] (?<buttons>(?:\((?:\d,?+)+\)\s?)+) \{(?<joltages>(?:\d,?)+)\}",
    )
    .unwrap()
});

fn parse_input(input: &str) -> Vec<Machine> {
    let mut machines = vec![];

    for line in input.trim().split("\n") {
        let captures = MACHINE_SPEC.captures(line).unwrap();

        let nlights = captures["target_lights"].len() as u8;
        let target_lights = captures["target_lights"]
            .match_indices('#')
            .map(|(idx, _)| idx as u8)
            .collect();

        let buttons = captures["buttons"]
            .split_whitespace()
            .map(|button| {
                let lights = button
                    .split(",")
                    .map(|light| light.trim_matches(['(', ')']).parse::<u8>().unwrap())
                    .collect();
                lights
            })
            .collect();

        let joltages = captures["joltages"]
            .split(",")
            .map(|joltage| joltage.parse::<u32>().unwrap())
            .collect();

        machines.push(Machine {
            nlights,
            target_lights,
            buttons,
            joltages,
        })
    }

    machines
}

fn p1(machines: &[Machine]) -> usize {
    machines.iter().map(|machine| machine.min_presses()).sum()
}

fn main() {
    let input = parse_input(&fs::read_to_string("../inputs/d10.txt").unwrap());
    let p1_ans = p1(&input);
    assert_eq!(p1_ans, 385);
    println!("p1: {p1_ans}");
}

#[cfg(test)]
mod tests {
    use super::*;

    static TEST_INPUT: LazyLock<Vec<Machine>> = LazyLock::new(|| {
        parse_input(
            "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
",
        )
    });

    #[test]
    fn test_input() {
        let test_input = &*TEST_INPUT;

        assert_eq!(test_input[0].min_presses(), 2);
        assert_eq!(test_input[1].min_presses(), 3);
        assert_eq!(test_input[2].min_presses(), 2);
        assert_eq!(p1(test_input), 7);
    }
}
