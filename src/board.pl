:- module(board,[
  empty_board/1,
  board_set/3,
  board_set/4,
  field/1,
  adjacent/2,
  mill/3,
  in_mill/2,
  board_field_piece/3,
  board_code/2
]).
:- use_module(setters).
:- use_module(bake).

arg0(N,T,Arg):-
	when((ground(N);ground(M)),succ(N,M)),
	arg(M,T,Arg).

:- setters(board/24).

empty_board(board(
              empty,empty,empty,empty,
              empty,empty,empty,empty,
              empty,empty,empty,empty,
              empty,empty,empty,empty,
              empty,empty,empty,empty,
              empty,empty,empty,empty
           )
         ).


color_digit(empty,0).
color_digit(white,1).
color_digit(black,2).

board_code(Board,Code):-
	(   number(Code)
	->  code_board(Code,Board)
	;   aggregate_all(sum(X),(
			      arg0(S,Board,Color),
			      color_digit(Color,C),
			      X is C * 3 ^ S
			  ),Code)
	).


code_digits(0,_Base,[]):-!.
code_digits(Code,Base,[Digit|Digits]):-
	Digit is Code mod Base,
	Rest is Code div Base,
	code_digits(Rest,Base,Digits).


code_board(Code,Board):-
	code_digits(Code,3,Digits),
	digits_pieces(Digits,1,Pieces),
	empty_board(Board0),
	board_set(Pieces,Board0,Board).


digits_pieces([],_,[]).
digits_pieces([Digit|Digits],N,[N=Color|Pieces]):-
	color_digit(Color,Digit),
	succ(N,M),
	digits_pieces(Digits,M,Pieces).


board_set([],In,In).
board_set([Field=Player|FieldsPlayers],In,Out):-
	board_set(Field,In,Player,In1),
	board_set(FieldsPlayers,In1,Out).

field(A):-
	between(1,24,A).

field_square(Field,Square):-
	field_coordinates(Field,_,Square).

field_line(Field,Line):-
	field_coordinates(Field,Line,_),
	1 is Line mod 2.

field_coordinates(Field,Angle,Square):-
	(   ground(Field)
	->  Angle is Field mod 8,
	    Square is Field // 8
	;   between(0,7,Angle),
	    between(0,2,Square),
	    Field is Square * 8 + Angle
	).

adjacent_(A,B):-
  adjacent_square(A,B).
adjacent_(A,B):-
  adjacent_line(B,A).

adjacent_square(A,B):-
	field_square(A,Fg),
	field_square(B,Fg),
	Dist is (A-B) mod 8,
	memberchk(Dist,[1,7]).

adjacent_line(A,B):-
	field_line(A,Sp),
	field_line(B,Sp),
	field_square(A,FgA),
	field_square(B,FgB),
	1 is abs(FgA-FgB).

adjacent(1,9).
adjacent(9,17).
adjacent(3,11).
adjacent(19,11).
adjacent(21,13).
adjacent(13,5).
adjacent(7,15).
adjacent(15,23).

adjacent(9,1).
adjacent(17,9).
adjacent(11,3).
adjacent(11,19).
adjacent(13,21).
adjacent(5,13).
adjacent(15,7).
adjacent(23,15).

:- bake(adjacent(A1,B1),(adjacent_(A,B),succ(A,A1),succ(B,B1))).

board_field_piece(Board,Field,Player):-
  arg(Field,Board,Player).

mill(1,2,3).
mill(9,10,11).
mill(17,18,19).
mill(8,16,24).
mill(4,12,20).
mill(21,22,23).
mill(13,14,15).
mill(5,6,7).
mill(1,7,8).
mill(9,15,16).
mill(17,23,24).
mill(2,10,18).
mill(6,14,22).
mill(19,20,21).
mill(11,12,13).
mill(3,4,5).
mill(1,9,17).
mill(3,11,19).
mill(21,13,5).
mill(7,15,23).

perm(A,B,C,A,B,C).
perm(A,B,C,A,C,B).
perm(A,B,C,B,A,C).
perm(A,B,C,B,C,A).
perm(A,B,C,C,A,B).
perm(A,B,C,C,B,A).


:- bake(mill_perm(A,B,C),(
	perm(A,B,C,A0,B0,C0),
	mill(A0,B0,C0))).

in_mill(Board,Field):-
	mill_perm(Field,B,C),
	arg(Field,Board,Player),
        Player \= empty,
	arg(B,Board,Player),
	arg(C,Board,Player).
