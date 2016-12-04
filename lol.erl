%% @doc Erlang mini project.
-module(lol).
-export([]).

%% @doc Splits a list or function into 4 sub-lists
splitToChunk([], SplittedList) -> 
	lists:reverse(SplittedList);

splitToChunk(List, []) ->
	LengthOfList = length(List),
	Remainder = LengthOfList rem 4,
	TotalZeroes = 4 - Remainder, %% (10 - 12) finds the number of zeores needed
	ListOne = lists:reverse(List), %% reverses List for efficiency 
	ListTwo = zeroes(ListOne, TotalZeroes), %%uses your zeores function. Not sure if it'd work.
	ListThree = lists:reverse(ListTwo), % reverse List 2 for efficiency 
	ChunkedList = lists:split(4, ListThree), %% splits list 3 into 4 chunks
	[Head|Tail] = ChunkedList, %% seperates the chuncked list into head and tail
	splitToChunk(Tail, [Head]);

splitToChunk(List, SplittedList) -> 
	ChunkedList2 = lists:split(4, List),
	[Head|Tail] = ChunkedList2,
	splitToChunk(Tail, lists:append(SplittedList, [Head])).
