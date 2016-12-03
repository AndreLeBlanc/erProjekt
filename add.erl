%% @doc Erlang mini project.
-module(add).
-export([start/3, start/4, listify/2, zeros/2, tupleMaker/2, makeArgs/2,  crunchNum/4, doCalc/7, addProc/4, doCalcDelay/8]).


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
    start(A, B, Base, none).


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
    
    {Sum, Carry} = go(MathArgs, Options, Base, self()),
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


% Launch processes that do the calculations and return the results.
-spec go(MathArgs, Options, Base, PID) -> tuple() when
      MathArgs::list(),
      Options::atom() | tuple(),
      Base::integer(),
      PID::integer().

go([], Options, Base, PID) ->
  PID!0,
  receive
    {Tot, Carried, CarriedList} ->
    io:format("addition complete~n"),
    {[Carried|Tot], [Carried|CarriedList]}
  end;

go([H|T], Options, Base, PID) ->
  NextPid = spawn(add, addProc, [H, Options, Base, PID]),
  io:format("new process started"),
  go(T, Options, Base, NextPid). 

% Adds two digits
-spec crunchNum(A, B, N, Base) -> tuple() when
      A::integer(),
      B::integer(),
      N::integer(),
      Base::integer().

crunchNum(A, B, N, Base) ->
  if A + B  + N < Base ->
      {(A + B + N), 0};
    true ->
      {((A + B + N) rem Base), 1}
  end.

% Does a calculation without a delay
-spec doCalc(NumTuple, Base, N, Sums, Carri, Id, Daddy) -> void when
      NumTuple::tuple(),
      Base::integer(),
      N::integer(),
      Sums::list(),
      Carri::list(),
      Id::atom(),
      Daddy::pid().

doCalc({[], []}, Base, N, Sums, Carri, Id, Daddy) ->
  Daddy!{Sums, Carri, N, Id};

doCalc({[FA|LA], [FB|LB]}, Base, N, Sums, Carri, Id, Daddy) ->
  {Tot, Car} = crunchNum(FA, FB, N, Base),
  doCalc({LA, LB}, Base, Car, [Tot|Sums], [N|Carri], Id, Daddy).
  
% Does a calculation with a delay
-spec doCalcDelay(NumTuple, Base, N, Sums, Carri, Id, Options, Daddy) -> void when
      NumTuple::tuple(),
      Base::integer(),
      N::integer(),
      Sums::list(),
      Carri::list(),
      Id::atom(),
      Options::tuple(),
      Daddy::pid().

doCalcDelay({[], []}, Base, N, Sums, Carri, Id, {Min, Max}, Daddy) ->
  Daddy!{Sums, Carri, N, Id};

doCalcDelay({[FA|LA], [FB|LB]}, Base, N, Sums, Carri, Id, {Min, Max}, Daddy) ->
  NapLen = Min + rand:uniform(Max - Min),
  io:format("zzzzzzzz~n"),
  timer:sleep(NapLen),
  {Tot, Car} = crunchNum(FA, FB, N, Base),
  doCalcDelay({LA, LB}, Base, Car, [Tot|Sums], [N|Carri], Id, {Min, Max}, Daddy).
  
% Retrieves the result from the spawned proccesses. 
-spec comeChildren(N, A, B) -> tuple() when
      N::integer(),
      A::integer(),
      B::integer().

comeChildren(2, A, B) ->
  {A, B};

comeChildren(N, A, B) ->
  receive
    {D, E, F, zero} ->
      comeChildren((N+1), {D, E, F}, B);
    {D, E, F, one} ->
      comeChildren((N+1), A, {D, E, F})
  end.

% The spawned processes
-spec addProc(NumTuple, Options, Base, PID) -> void when
      NumTuple::tuple(),
      Options::tuple() | atom(),
      Base::integer(),
      PID::integer().

addProc(NumTuple, Options, Base, PID) ->
  Me = self(),
  if 
    Options == none ->
      spawn(add, doCalc, [NumTuple, Base, 0, [], [], zero, Me]),
      spawn(add, doCalc, [NumTuple, Base, 1, [], [], one, Me]);
    true ->
      spawn(add, doCalcDelay, [NumTuple, Base, 0, [], [], zero, Options, Me]),
      spawn(add, doCalcDelay, [NumTuple, Base, 1, [], [], one, Options, Me])
  end,

  comeChildren(0, {}, {}).



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