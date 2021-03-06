% procedures dynamiques de notre programme avec leur arite
:- dynamic dimension/1.
:- dynamic position/1.
:- dynamic slot/3.
:- dynamic next_idle_grid_id/1. 
:- dynamic end_of_game/1.
:- dynamic no_legal_move/0.
:- dynamic player_stuck/1.  
:- dynamic pos_evaluation/4. 

% permet de supprimer toutes les regles et faits pendant le deroulement du programme
cleanup:-
	retractall(dimension(_)),
	retractall(position(_)),
	retractall(slot(_,_,_)),
	retractall(next_idle_grid_id(_)),
	retractall(end_of_game(_)),
	retractall(no_legal_move),
	retractall(player_stuck(_)),
	retractall(pos_evaluation(_,_,_,_)).

% liste des mouvements possibles
direction_list([north,northEast,east,southEast,south,southWest,west,northWest]).
% plateau initial, les 4 pieces occupants les postions((4,4),(5,5),(4,5),(5,4))
initialize_board(N):-
	assert(dimension(N)),				 
	initialize_starting_pos_grid(1,1,N), 
	assert(next_idle_grid_id(1)).	

initialize_starting_pos_grid(N,N,N):-		
	assert(slot(0,position(N,N),0)),!.

initialize_starting_pos_grid(I,J,N):-
	((I =:= N/2, J =:= N/2, !, Val = 1)
	;
	(I =:= N/2, J =:= (N/2)+1, !, Val = 2)
	;
	(I =:= (N/2)+1, J =:= N/2, !, Val = 2)
	;
	(I =:= (N/2)+1, J =:= (N/2)+1, !, Val = 1) 
	;
	(Val = 0)),				
	
	assert(slot(0,position(I,J),Val)),		
	get_next_sequential_index(I, J, NewI, NewJ,N),
	initialize_starting_pos_grid(NewI,NewJ,N).	

get_next_sequential_index(I, J, NewI, NewJ,N):-
	(I =< N, J < N, !, NewI is I, NewJ is J+1)
	;
	(I < N, J =:= N, !, NewI is I+1, NewJ is 1).

get_next_directional_index(I,J,NewI,NewJ,Direction):-
	Up is I-1, 
	Down is I+1,
	Right is J+1,
	Left is J-1,
	((Direction = north,!, NewI is Up, NewJ is J)
	;
	(Direction = northEast,!, NewI is Up, NewJ is Right)
	;
	(Direction = east,!, NewI is I, NewJ is Right)
	;
	(Direction = southEast,!, NewI is Down, NewJ is Right)
	;
	(Direction = south,!, NewI is Down, NewJ is J)
	;
	(Direction = southWest,!, NewI is Down, NewJ is Left)
	;
	(Direction = west,!, NewI is I, NewJ is Left)
	;
	(Direction = northWest,!, NewI is Up, NewJ is Left)).
% dessine le plateau du jeu
% IdBoard represente le numero identifiant de notre plateau
% N represente la dimension du plateau
% appelle des fonctions draw_board_header et draw_board 
draw_board(IdBoard):-
	dimension(N),
	nl, tab(5),
	draw_board_header(1,N),  
	draw_board(IdBoard,1,1,N).
% permet de dessiner le plateau du jeu
% - represente les positions vides 
% x represente les positions contenant une piece noire
% o represente les positions contenant une piece blanche
% appelle de la fonction get_next_sequential_index
draw_board(IdBoard,I,J,N):-
	slot(IdBoard,position(I,J),Val),
	WidthSpace = 1,
	((Val = 0, write('[-]'), tab(WidthSpace)) 
	;
	 (Val = 1, write('[x]'), tab(WidthSpace))
	;
	 (Val = 2, write('[o]'), tab(WidthSpace))),
	
	(I =:= N, J =:= N, !, nl) 
	;
	(get_next_sequential_index(I, J, NewI, NewJ,N),
	((NewI > I,!, nl, write(NewI), 
	  ((NewI < 10,!, tab(5)) ; tab(2)));
	(NewI =:= I)),
	draw_board(IdBoard,NewI,NewJ,N)).
% permet de numeroter les cases de facon horizontale
draw_board_header(J,N):-
	(J =< 10,!, tab(1),write('['),write(J),write(']')),
	((J =:= N, !, nl, write(1), tab(5));
	(NewJ is J+1, draw_board_header(NewJ,N))).

duplicate_grid(IdBoard, NewIdBoard):-
	dimension(N),
	retract(next_idle_grid_id(NewIdBoard)),
	NextIdleID is NewIdBoard + 1,
	assert(next_idle_grid_id(NextIdleID)),
	duplicate_grid(IdBoard, NewIdBoard,1,1,N).  

duplicate_grid(IdBoard, NewIdBoard,I,J,N):-
	slot(IdBoard,position(I,J),Val),
	assert(slot(NewIdBoard,position(I,J),Val)),
	(I =:= N, J =:= N,!)
	;
	(get_next_sequential_index(I, J, NewI, NewJ,N), 
	 duplicate_grid(IdBoard, NewIdBoard,NewI,NewJ,N)).
% change la couleur des pieces selon la direction
flip_pieces(IdBoard,position(I,J),Val):-
	direction_list(DirectionList),
	(member(Direction, DirectionList), 
	get_next_directional_index(I,J,NewI,NewJ,Direction),
	getListOfCoordinatesToFlip(IdBoard,position(NewI,NewJ),Val,Direction,CoordinatesList),
	flip_list(IdBoard,Val,CoordinatesList),
	fail)	
	;
	true.
% retourne la liste des pieces à changer leur valeur apres une main du joueur
getListOfCoordinatesToFlip(IdBoard,position(I,J),Val,Direction,[Head|Tail]):-
	slot(IdBoard,position(I,J),CurrentVal), 
	CurrentVal =\= 0,!,
	((CurrentVal =:= Val,!, Head = [], Tail = [])
	;
	(Head = position(I,J),
	get_next_directional_index(I,J,NewI,NewJ,Direction),
	getListOfCoordinatesToFlip(IdBoard,position(NewI,NewJ),Val,Direction,Tail))).
	
% liste vide
flip_list(_,_,[]):-!.		
% change la valeur de la liste de pieces enclerclees				
flip_list(IdBoard,Val,[Coordinate|Tail]):-	
	retract(slot(IdBoard,Coordinate,_)),		
	assert(slot(IdBoard,Coordinate,Val)),	
	flip_list(IdBoard,Val,Tail).			


makeLegalMove(position(I,J), pos(Grid1Id,Player1,_), pos(Grid2Id,Player2,position(I,J))):-
	((not(var(I)), not(var(J)),!);
	slot(Grid1Id,position(I,J),0)),
	(slot(Grid1Id,position(I,J),0), 
	validate_position(Grid1Id,position(I,J),Player1),
	duplicate_grid(Grid1Id,Grid2Id), 
	retract(slot(Grid2Id,position(I,J),_)),
	assert(slot(Grid2Id,position(I,J),Player1)),
	flip_pieces(Grid2Id,position(I,J),Player1),
	((Player1 =:= 1, Player2 is 2) ; (Player1 =:= 2, Player2 is 1))).
	

validate_position(IdBoard,position(I,J),RequestedVal):-	
	direction_list(DirectionList),		
	member(Direction, DirectionList),
	get_next_directional_index(I,J,NewI,NewJ,Direction),
	slot(IdBoard,position(NewI,NewJ),Val),
	Val =\= 0,
	abs(Val-RequestedVal) =:= 1, 
	validate_direction_recursively(IdBoard,position(NewI,NewJ),RequestedVal,Direction).
	
validate_direction_recursively(IdBoard,position(I,J),RequestedVal,Direction):-
	get_next_directional_index(I,J,NewI,NewJ,Direction),
	slot(IdBoard,position(NewI,NewJ),Val),
	Val =\= 0,
	((Val =:= RequestedVal,!)	
	;	
	(validate_direction_recursively(IdBoard,position(NewI,NewJ),RequestedVal,Direction))).

get_legal_positions(Id,Player,Coordinates):-
	setof((I,J),(slot(Id,position(I,J),0),validate_position(Id,position(I,J),Player)),Coordinates).
	