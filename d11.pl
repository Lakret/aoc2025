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
  { ConnectionCodes = [_ | _], atom_codes(Connection, ConnectionCodes) },
  !.

:- dynamic device/2.

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

p1(Count) :-
  init_db,
  findall('', valid_path, Paths),
  length(Paths, Count).

valid_path2 :- valid_path2(svr, false, false, []).

valid_path2(out, true, true, _).
valid_path2(dac, false, FFT_Visited, Visited) :-
  device(dac, Connections),
  NewVisited = [dac | Visited],
  !,
  member(NextDevice, Connections),
  valid_path2(NextDevice, true, FFT_Visited, NewVisited).
valid_path2(fft, DAC_Visited, false, Visited) :-
  device(fft, Connections),
  NewVisited = [fft | Visited],
  !,
  member(NextDevice, Connections),
  valid_path2(NextDevice, DAC_Visited, true, NewVisited).
valid_path2(Device, _, _, Visited) :-
  member(Device, Visited),
  !,
  fail.
valid_path2(Device, DAC_Visited, FFT_Visited, Visited) :-
  NewVisited = [Device | Visited],
  device(Device, Connections),
  member(NextDevice, Connections),
  valid_path2(NextDevice, DAC_Visited, FFT_Visited, NewVisited).

% device(svr, [aaa, bbb]).
% device(aaa, [fft]).
% device(fft, [ccc]).
% device(bbb, [tty]).
% device(tty, [ccc]).
% device(ccc, [ddd, eee]).
% device(ddd, [hub]).
% device(hub, [fff]).
% device(eee, [dac]).
% device(dac, [fff]).
% device(fff, [ggg, hhh]).
% device(ggg, [out]).
% device(hhh, [out]).

p2(Count) :-
  init_db,
  findall('', valid_path2, Paths),
  length(Paths, Count).
