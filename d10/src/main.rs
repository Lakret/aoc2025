use regex::Regex;
use std::collections::{HashMap, HashSet};
use std::fs;
use std::sync::LazyLock;

type Button = Vec<u8>;

#[derive(Debug, Clone)]
struct Machine {
    nlights: u8,
    target_lights: HashSet<u8>,
    buttons: Vec<Button>,
    joltages: Vec<u16>,
}

impl Machine {
    // Implemented by doing a breadth-first search on a tree of states.
    fn min_presses(&self) -> usize {
        let mut states: Vec<HashSet<u8>> = vec![HashSet::new()];
        let mut new_states = vec![];
        let mut level = 1;

        let buttons = self
            .buttons
            .iter()
            .map(|button| button.iter().copied().collect::<HashSet<_>>())
            .collect::<Vec<_>>();

        loop {
            for state in &states {
                for button in &buttons {
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

    // TODO: Dijkstra?
    fn min_presses_p2(&self) -> usize {
        let mut states: Vec<Vec<u16>> = vec![vec![0; self.nlights as usize]];
        let buttons = self
            .buttons
            .iter()
            .map(|button| button.iter().map(|&idx| idx as u16).collect::<Vec<_>>())
            .collect::<Vec<_>>();
        let mut new_states = vec![];
        let mut level = 1;

        loop {
            for state in &states {
                for button in &buttons {
                    let new_state = apply_joltages(state, button);
                    let mut solution = true;

                    for (idx, &joltage) in new_state.iter().enumerate() {
                        if joltage > self.joltages[idx] {
                            solution = false;
                            break;
                        }

                        if joltage < self.joltages[idx] {
                            solution = false;
                        }
                    }

                    if solution {
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

fn apply_joltages(state: &[u16], button: &[u16]) -> Vec<u16> {
    let mut new_state = state.to_vec();

    for &idx in button {
        new_state[idx as usize] += 1u16;
    }

    new_state
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
            .map(|joltage| joltage.parse::<u16>().unwrap())
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

fn p2(machines: &[Machine]) -> usize {
    machines
        .iter()
        .map(|machine| machine.min_presses_p2())
        .sum()
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
    fn test_p1() {
        let test_input = &*TEST_INPUT;

        assert_eq!(test_input[0].min_presses(), 2);
        assert_eq!(test_input[1].min_presses(), 3);
        assert_eq!(test_input[2].min_presses(), 2);
        assert_eq!(p1(test_input), 7);
    }

    #[test]
    fn test_p2() {
        let test_input = &*TEST_INPUT;

        // assert_eq!(apply_joltages(&[3, 5, 4, 7], &[1, 3]), vec![3, 6, 4, 8]);
        assert_eq!(test_input[0].min_presses_p2(), 10);
    }
}
