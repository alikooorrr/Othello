max_to_move(pos(_,1,_)). % max represente le joueur humain 
min_to_move(pos(_,2,_)).  % min represente le joueur machine

moves(Pos,PosList,DepthLevel,MaxDepth):-
	DepthLevel =< MaxDepth,
	setof(pos(Id,Player,position(I,J)),makeLegalMove(position(I,J),Pos,pos(Id,Player,position(I,J))),PosList). 
% fonction permettant de determiner la plus bonne valeur pour le joueur humain et le joueur machine
minimax(CurrentPos,BestSuccessorPos,Val,DepthLevel,MaxDepth,Level):-
	ActualDepth is MaxDepth - DepthLevel,
	CurrentPos = pos(Grid,_,_),
	get_hash_key(Grid,HashKey),
	((pos_evaluation(HashKey,ActualDepth,BestSuccessorPos,Val),!); 
	(moves(CurrentPos,PosList,DepthLevel,MaxDepth),!,
	 NewDepthLevel is DepthLevel+1,
	 boundedbest(PosList,BestSuccessorPos,Val,NewDepthLevel,MaxDepth,Level),
	 assert(pos_evaluation(HashKey,ActualDepth,BestSuccessorPos,Val)));
	staticval(CurrentPos,Val,Level)).  

boundedbest([Pos|PosList],GoodPos,GoodVal,DepthLevel,MaxDepth,Level):-
	minimax(Pos,_,Val,DepthLevel,MaxDepth,Level),
	goodenough(PosList,Pos,Val,GoodPos,GoodVal,DepthLevel,MaxDepth,Level).

goodenough([],_,_,Pos,Val,Pos,Val,_,_,_):- !.

goodenough(_,Pos,Val,Pos,Val,_,_,_):-
	min_to_move(Pos),!;
	max_to_move(Pos),!.

goodenough(PosList,Pos,Val,GoodPos,GoodVal,DepthLevel,MaxDepth,Level):- 
	boundedbest(PosList,Pos1,Val1,DepthLevel,MaxDepth,Level),
	betterof(Pos,Val,Pos1,Val1,GoodPos,GoodVal).


betterof(Pos,Val,_,Val1,Pos,Val):- 
	min_to_move(Pos),Val > Val1, !;
	max_to_move(Pos), Val < Val1, !.

betterof(_,_,Pos1,Val1,Pos1,Val1). 

staticval(pos(IdBoard,_,_),Val,Level):- 
	(Level =:= 2,!,
	 pieces_count_evaluation(IdBoard,CountVal,_,_),
	 mobility_evaluation(IdBoard,MobilityVal),
	 Val is (0.4 * CountVal) + (0.6 * MobilityVal)).

pieces_count_evaluation(IdBoard,Val,MaxCount,MinCount):-
	pieces_count(IdBoard,MaxCount,0,MinCount,0,1,1),
	TotalCount is MaxCount + MinCount,
	Val is (MaxCount - MinCount) / TotalCount.

pieces_count(Id,MaxTotal,MaxTemp,MinTotal,MinTemp,I,J):-
	slot(Id,position(I,J),CurrentVal), 
	((CurrentVal =:= 0,!, NewMaxTemp is MaxTemp, NewMinTemp is MinTemp)
	;
	(CurrentVal =:= 1,!, NewMaxTemp is MaxTemp+1, NewMinTemp is MinTemp)
	;
	(CurrentVal =:= 2,!, NewMinTemp is MinTemp+1, NewMaxTemp is MaxTemp)),
	dimension(N),
	(((I =:= N, J =:= N,!, MaxTotal is NewMaxTemp, MinTotal is NewMinTemp));
	(get_next_sequential_index(I,J,NewI,NewJ,N),
	pieces_count(Id,MaxTotal,NewMaxTemp,MinTotal,NewMinTemp,NewI,NewJ))).

mobility_evaluation(Grid,Val):-
	((((get_legal_positions(Grid,1,MaxMoves),!, length(MaxMoves,MaxCount)) ;
	 MaxCount is 0),
	((get_legal_positions(Grid,2,MinMoves),!, length(MinMoves,MinCount));
	 MinCount is 0)),
	(Delta is MaxCount - MinCount,
	TotalCount is MaxCount + MinCount,
	((TotalCount =:= 0,!, Val is 0) ; (Val is Delta / TotalCount)))).
    
corners_evaluation(IdBoard,Val):-  
	dimension(N),
	slot(IdBoard,position(1,1),C1),
	slot(IdBoard,position(1,N),C2),
	slot(IdBoard,position(N,1),C3),
	slot(IdBoard,position(N,N),C4),
	((C1 =:= 0,!,C1Val is 0) ; (C1 =:= 1,!,C1Val is 0.25) ; (C1Val is -0.25)),
	((C2 =:= 0,!,C2Val is 0) ; (C2 =:= 1,!,C2Val is 0.25) ; (C2Val is -0.25)),
	((C3 =:= 0,!,C3Val is 0) ; (C3 =:= 1,!,C3Val is 0.25) ; (C3Val is -0.25)),
	((C4 =:= 0,!,C4Val is 0) ; (C4 =:= 1,!,C4Val is 0.25) ; (C4Val is -0.25)),
	 
	Val is C1Val+C2Val+C3Val+C4Val.	
	
get_hash_key(Grid,HashKey):-
	dimension(N),
	get_hash_key(Grid,GridFlatList,1,1,N),
	name(HashKey,GridFlatList).	
			
get_hash_key(Grid,[Val],N,N,N):-	
	slot(Grid,position(N,N),Val),!.
	
get_hash_key(Grid,[Head|Tail],I,J,N):-		
	slot(Grid,position(I,J),Head),!,
	get_next_sequential_index(I,J,NewI,NewJ,N),
	get_hash_key(Grid,Tail,NewI,NewJ,N).