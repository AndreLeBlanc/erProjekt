%% @doc Erlang mini project.
-module(add).
-export([start/3, start/4, listify/2, zeros/2, tupleMaker/2, makeArgs/2]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%                       INIT                       %%%%%%%%%                                  
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% @doc TODO: add documentation
-spec start(A,B,Base) -> ok when 
      A::integer(),
      B::integer(), 
      Base::integer().

start(A,B, Base) ->
    start(A, B, Base, [none]).


%% @doc TODO: add documentation
-spec start(A,B,Base, Options) -> ok when 
      A::integer(),
      B::integer(), 
      Base::integer(),
      Option::atom() | tuple(),
      Options::[Option].

start(A,B,Base, Options) ->
    ListOfA = listify(A),
    ListOfB = listify(B),
    {AZero, BZero} = tupleMaker(A, B),
    SplitA = splitToChunk(lists:reverse(AZero)), 
    SplitaB = splitToChunk(lists:reverse(BZero)),
    MathArgs = makeArgs(SplitA, SplitaB),
    
    go(MathArgs, Options, self()),
    {Sum, Carry} = {sum, carry},
    printRes(ListOfA, ListOfB, Sum, Carry).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%                  Making lists                    %%%%%%%%%                                  
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% toList makes a list of digits out of a number. toList(15) = [1,5]
-spec listify(X) -> list() when
      X:: integer().

listify(A) ->
  listify(A, []).

-spec listify(X, DigiList) -> list() when
      X:: integer(),
      DigiList::list().

listify(X, DigiList) ->
  if X == 0 -> 
    DigiList;
  true -> 
    listify((X div 10), [X rem 10 | DigiList])
  end.

% Appends 0 to the list until it is as long as length
-spec zeros(List, Length) -> list() when
      List::list(),
      Length::integer().

zeros(List, Length) when length(List) == Length ->
  List;

zeros(List, Length) ->
  zeros([0|List], Length).

% makes a touple with the two lists
-spec tupleMaker(AList, BList) -> tuple() when
      AList::list(),
      BList::list().

tupleMaker(AList, BList) ->
  if 
    length(AList) == length(BList) ->
      {AList, BList};
    length(AList) > length(BList) ->
      {AList, zeros(BList, length(AList))};
    true ->
      {zeros(AList, length(BList)), BList}
  end.

% Makes a list of tuples of corresponding elements from two lists.
% Example: A = [[1,2], [3,4]] B = [[5,6], [7,8]]. makeArgs(A, B) = 
% [{[1,2], [5,6]}, {[3,4], [7,8]}]
-spec makeArgs(A, B) -> list() when
      A::list(),
      B::list().

makeArgs(A, B) ->
  makeAux(A, B, []).

% Implements makesArgs
-spec makeAux(A, B, Args) -> list() when
      A::list(),
      B::list(),
      Args::list().

makeAux([H|T], [I|J], Args) ->
  makeAux(T, J, [{H, I} | Args]);

makeAux(A, B, Args) ->
  Args.

splitToChunk(List) -> 
  tbi.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%                Math and processes                %%%%%%%%%                                  
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

go(MathArgs, Options, PID) ->
  tbi.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%                     Printing                     %%%%%%%%%                                  
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


printRes(ListOfA, ListOfB, Sum, Carry) ->
  tbi.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%                       Tests                      %%%%%%%%%                                  
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%