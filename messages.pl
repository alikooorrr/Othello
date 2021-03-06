% fontion interactive du jeu
game(Mode,Level,pos(IdBoard,Player1,_)):-	 
	(get_legal_positions(IdBoard,Player1,ValidCoordinates),
	 retractall(player_stuck(_)),
	 
	((Mode =:= Player1,!,	
	 get_position_from_user(Player1,ValidCoordinates,UserCoordinate),
	 makeLegalMove(UserCoordinate,pos(IdBoard,Player1,_),pos(NewId,Player2,_)));		
	(Level is 2, MaxDepth is 3,
	 minimax(pos(IdBoard,Player1,_),pos(NewId,Player2,position(I,J)),_,0,MaxDepth,Level),
	 print_computer_move(I,J))),
	 (not(end_of_game(_)),nl,
	  draw_board(NewId), sleep(1),
	  ((Mode =:= Player1,!, sleep(1)) ; (sleep(0.75))),
	  game(Mode,Level,pos(NewId,Player2,_))));
	  (assert(player_stuck(Player1)),
		get_other_player(Player1,Player2),
		not(end_of_game(_)),
		(((player_stuck(Player2),!,print_no_moves_message,assert(end_of_game(IdBoard)),fail)); 
		(print_skip_turn_message(Mode,Player1),
		 game(Mode,Level,pos(IdBoard,Player2,_))))).

get_other_player(Player1,Player2):-
	(Player1 =:= 1,!, Player2 is 2);
	(Player1 =:= 2, Player2 is 1).

get_user_input(InputString):-
	get(C), 
	parse_rest_of_line(Rest),  
	append([C],Rest,InputCharacterList), 	
	name(InputString,InputCharacterList). 
	
parse_rest_of_line(Result):-
	get0(C), 
	((C = 10,!, Result = []);	
	(C = 32,!,Result = [], drop_rest_of_line);
	(Result = [C|Rest], parse_rest_of_line(Rest))).
	 
drop_rest_of_line:-
	get0(C), ((C = 10,!) ; (drop_rest_of_line)).

% donne la position choisie par le joueur
% repete le message tant que le joueur donne une position invalide 		 
get_position_from_user(Player, ValidCoordinates,Coordinate):-
	nl, write("It's your turn to place a piece. Write a position on format type (I,J): 'I' like a row and 'J' like a column"),nl,
	(Player =:= 1,!, write('You need to place an "x" on the board')),nl,
	repeat, 
	prompt_user_to_move(ValidCoordinates),
	get_user_input(UserInput),
	% 40 est la valeur ascii de la parenthese ouvrante
    % 41 est la valeur ascii de la virgule
    % 44 est la valeur ascii de la parenthese fermante
	((name(UserInput,[40,X,44,Y,41|_]),  
	  name(I,[X]),name(J,[Y]),member((I,J),ValidCoordinates),!,Coordinate=position(I,J));
	 print_invalid_input_message(UserInput), fail).	 

% bienvenue au jeu
print_welcome_message:-
	write('Hello, Welcome to this game Othello H21'),nl.
% specifiant que le format ou la position ecrit par le joueur humain est invalide
% La variale Input represente la position donnée par le joueur humain
print_invalid_input_message(Input):-
	write('The input '),write(Input),write(' is invalid. Try again.'),nl,nl.
% position choisie par le joueur machine
print_computer_move(I,J):-
	nl, write('Machine player plays to position ('),
	write(I),write(','),write(J),write(').').

% montre que le joueur actuel ne peut pas jouer et doit ceder la main à son adversaire
print_skip_turn_message(Mode,PlayerNum):-
	Mode =:= PlayerNum, !, 
	 nl, write('I am sorry, you have no legal moves, therefore your turn is skipped.');
	(nl, write('Oh shoot!, I''m stuck without any legal moves, my turn is skipped.'),nl).

print_no_moves_message:-
	nl,write('Apparently, we both have no legal moves left,'),nl,
	write('therefore this game has come to it''s end.').
% message contenant la liste des positions Valides	
% ValidCoordinates represente la liste des postions valides
prompt_user_to_move(ValidCoordinates):-
	write("The possible positions are: "),
	write(ValidCoordinates),nl.

% résultat final du jeu 
% TotalBlack represente le nombre de pieces total de types x
% TotalWhite represente le nombre de pieces total de types o
print_game_results(Mode,FinalGrid):- 
    % compter le nombre de piece x et o
	pieces_count_evaluation(FinalGrid,_,TotalBlack,TotalWhite),
	nl,write('We have '), write(TotalBlack),write(' pieces of X type in the board'),
	nl,write('We have '), write(TotalWhite),write(' pieces of O type in the board'),nl,nl,
	% match nul si x et o sont egales
	(((TotalBlack =:= TotalWhite),!, write("Draw, replay another partie."),nl); 
    % declare vainqueur final
	((Mode =:= 1, TotalBlack > TotalWhite),!,
	 write('You are the winner'), 
	 write('! Wow, great game!'),nl);									
	(write('Sorry , I am the winner'))).