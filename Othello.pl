% Legal move on the board
list_move_possible([north, northEast, east, southEast, south, southWest, west, northWest]).

:- dynamic position/1.
:- dynamic slot/3.


play :-
    write("Hello, welcome to this game Othello hiver 2021"), nl,
    write("What is your name ? "),
    read(PlayerName), nl,
    write(PlayerName),write(", now you can play with the machine player"), nl, nl, sleep(1),
    write("You are the \"x\" pieces and the machine player is the \"o\" pieces"), nl,
    write("You can start, it's your turn to move !!!"),
    board_initializing(8),
    draw_my_board.


% initialize the board of 8 * 8, 2 pieces "x" in position (4,4) and (5,5)
% 2 pieces "o" in position (4,5) and (5,4)
% board_initializing(N):- N equals 8 because we have a board 8 * 8
board_initializing(N):-
    initializing_first_pieces_position_grid(1,1,N).


% For the last slot in the right-bottom
initializing_first_pieces_position_grid(N, N, N) :-
    assert(slot(0, position(N,N), 0)), !.


% if Val = 1 attributes for pieces "x" else if Val = 2 for pieces "o" else Val =  0 is a empty square
initializing_first_pieces_position_grid(I,J,N) :-
    ((I =:= N/2, J =:= N/2, !, Val = 1)
     ;
     (I =:= (N/2)+1, J =:= (N/2) + 1, !, Val = 1)
     ;
     (I =:= N/2, J =:= (N/2) + 1, !, Val = 2)
     ;
     (I =:= (N/2) + 1, J =:= N/2, !, Val = 2)
     ;
     (Val = 0)
     ),
     assert(slot(0, position(I,J), Val)),
     get_next_index(I, J, NewI, NewJ, N),
     initializing_first_pieces_position_grid(NewI, NewJ, N).

/*
    Increment the I and J value for the initialising the board
*/
get_next_index(I, J, NewI, NewJ, N) :-
    (I =< N, J < N, !, NewI is I, NewJ is J + 1);
    (I  < N, J =:= N, !, NewI is I + 1, NewJ is 1).

draw_board(IdBoard,N) :-
    nl,nl,nl,
    tab(5),
    draw_board_index(1, N),
    draw_board(IdBoard, 1, 1, N).

draw_board(IdBoard, I, J, N) :-
    slot(IdBoard, position(I,J), Val),
    WidthSpace = 1,
    ((Val = 0, write("[-]"), tab(WidthSpace));
     (Val = 1, write("[x]"), tab(WidthSpace));
     (Val = 2, write("[o]"), tab(WidthSpace))
    ),
    (I =:= N, J =:= N, !, nl);
    (get_next_index(I, J, NewI, NewJ, N),
     ((NewI > I, !, nl, write(NewI),
     ((NewI < 10, !, tab(5)); tab(2)));
     (NewI =:= I)),
     draw_board(IdBoard, NewI, NewJ, N)).

draw_board_index(J, N) :-
    (J =< 10, !, tab(1), write("["),write(J),write("]")),
     ((J =:= N, !, nl, write(1),tab(5));
     (NewJ is J + 1, draw_board_index(NewJ, N))).

draw_my_board :-
    nl,
    draw_board(0,8).
