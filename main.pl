:- include('board.pl'). % appelle fichier board
:- include('minimax.pl'). % appelle fichier minimax
:- include('messages.pl'). % appelle fichier messages
% play permet de debuter le jeu
play:-
	print_welcome_message,
	N is 8,
	Mode is 1,	
	Level is 2,
	initialize_board(N),
	draw_board(0),
	 
	(Mode == 1, game(Mode,Level,pos(0,1,_)); 
	(end_of_game(FinalGrid),
	 print_game_results(Mode,FinalGrid),
	 cleanup)).