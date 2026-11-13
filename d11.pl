:- use_module(library(pio)).
:- use_module(library(dcg/basics)).

% ?- parse_input('inputs/d11.txt', Entries).
parse_input(File, Entries) :- phrase_from_file(lines(Entries), File).

lines([H | T]) --> line(H), "\n", !, lines(T).
lines([]) --> blanks, eos.

% ?- phrase(line(Device/Connections), `you: foo bar baz`).
line(Device/Connections) -->
  string_without(":", DeviceCodes),
  ":",
  whites, % important to use whites here, since blanks can consume newline
  connections(Connections),
  { atom_codes(Device, DeviceCodes) }.

connections([Connection | Rest]) -->
  connection(Connection),
  whites,
  connections(Rest).
connections([]) --> [].

connection(Connection) -->
  nonblanks(ConnectionCodes),
  { ConnectionCodes \= [], atom_codes(Connection, ConnectionCodes) },
  !.

:- dynamic([device/2], [incremental(true)]).

init_db :-
  parse_input('inputs/d11.txt', Entries),
  retractall(device(_, _)),
  forall(member(Device/Connections, Entries), assertz(device(Device, Connections))).

valid_path :- valid_path(you).

valid_path(out).
valid_path(Device) :-
  device(Device, Connections),
  member(NextDevice, Connections),
  valid_path(NextDevice).

%% p1(-Count).
%  Solution to p1 by finding all valid_path solutions and counting them.
p1(Count) :-
  init_db,
  findall('', valid_path, Paths),
  length(Paths, Count).

count_paths(Count) :- count_paths(svr, false, false, Count).

:- table count_paths/4 as incremental.

% instead of counting each path one by one, use dynamic programming -
% remember counts for each subtree and reuse them
count_paths(out, true, true, 1) :- !.
count_paths(out, _, _, 0) :- !.
count_paths(Device, SeenDAC, SeenFFT, Count) :-
  (Device == dac -> NextDAC = true; NextDAC = SeenDAC),
  (Device == fft -> NextFFT = true; NextFFT = SeenFFT),
  !,
  findall(
    NextCount,
    (
      device(Device, Connections),
      member(NextDevice, Connections),
      count_paths(NextDevice, NextDAC, NextFFT, NextCount)
    ),
    NextCounts
  ),
  sum_list(NextCounts, Count).

%% p2(-Count).
%  Solution to p2 by dynamic programming via tabling: count all paths in each valid subtree and sum them.
p2(Count) :-
  init_db,
  count_paths(Count).

% ?- call_time(p2(C), Time).
