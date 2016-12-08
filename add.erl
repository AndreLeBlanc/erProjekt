%% @doc Erlang mini project.
-module(add).
-export([start/3, start/4, listify/1, zeros/2, tupleMaker/2, makeArgs/2,  crunchNum/4, doCalc/7, addProc/4, doCalcDelay/8, go/4, printLast/1]).
-include_lib("eunit/include/eunit.hrl").


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
    {AZero, BZero} = tupleMaker(ListOfA, ListOfB),
    MathArgs = makeArgs(AZero, BZero),
    
    {Sum, Carry} = go(MathArgs, Options, Base, self()),
    printRes(A, B, Sum, Carry).

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

makeArgs(A, B) when length(A) =< 4 ->
  makeAuxShort(A, B, []);

makeArgs(A, B) ->
  Len = length(A) div 4,
  makeAuxLong(A, B, Len, []).

% Implements makesArgs with longer lists.
-spec makeAuxLong(A, B, Len, Args) -> list() when
      A::list(),
      B::list(),
      Len::integer,
      Args::list().

makeAuxLong([], [], Len, Args) ->
  Args;

makeAuxLong(A, B, Len, Args) ->
  if (length(A) < Len) ->
      C = lists:reverse(A),
      D = lists:reverse(B),
      Args ++ [{C, D}];
    true ->
      {Aite, ARemain} = lists:split(Len, A),
      {Bite, Bremain} = lists:split(Len, B),
      E = lists:reverse(Aite),
      F = lists:reverse(Bite),
      Arg = Args ++ [{E, F}],
      makeAuxLong(ARemain, Bremain, Len, Arg)
  end.

% Implements makesArgs
-spec makeAuxShort(A, B, Args) -> list() when
      A::list(),
      B::list(),
      Args::list().

makeAuxShort([H|T], [I|J], Args) ->
  makeAuxShort(T, J, Args ++ [{[H], [I]}]);

makeAuxShort(A, B, Args) ->
  Args.

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
      PID::pid().

go([], Options, Base, PID) ->
  PID!{[], [], 0},
  receive
    {Tot, CarriedList, Carried} ->
    io:format("addition complete~n"),
    {[Carried|Tot], CarriedList}
  end;

go([H|T], Options, Base, PID) ->
  NextPid = spawn(add, addProc, [H, Options, Base, PID]),
  io:format("new process started~n"),
  go(T, Options, Base, NextPid). 

% Adds two digits
-spec crunchNum(A, B, N, Base) -> tuple() when
      A::integer(),
      B::integer(),
      N::integer(),
      Base::integer().

crunchNum(A, B, N, Base) ->
  if (A + B  + N < Base) ->
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
  doCalc({LA, LB}, Base, Car, [Tot|Sums], [Car|Carri], Id, Daddy).
  
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
  doCalcDelay({LA, LB}, Base, Car, [Tot|Sums], [Car|Carri], Id, {Min, Max}, Daddy).
  
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

  {{DigitsNoCar, CarriNoCar, CarNoCar}, {DigitsCar, CarriCar, CarCar}} = comeChildren(0, {}, {}),
  
  receive
    {Sums, Carri, 0} ->
      Carrid = CarriNoCar ++ Carri,
      Sumz = DigitsNoCar ++ Sums,
      PID!{Sumz, Carrid, CarNoCar};
    {Sums, Carri, 1} ->
      Carrid = CarriCar ++ Carri,
      Sumz = DigitsCar ++ Sums,
      PID!{Sumz, Carrid, CarCar}
  end.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%                     Printing                     %%%%%%%%%                                  
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% print remainders
printCar([], A) ->
  io:format("~n");

printCar([1|T], A) ->
  io:format(A),
  printCar(T, A);

printCar([0|T], A) ->
  io:format(" "),
  printCar(T, A).

printUnder(0) ->
  io:format("~n");

printUnder(A) ->
  io:format("-"),
  printUnder(A-1).

printLast([H|T], start) ->
  if H == 0 ->
      printUnder(length(T)+2),
      io:format("  "),
      printLast(T);
    true ->
      printUnder(length(T)+3),
      io:format(" "),
      printLast([H|T])
  end.

printLast([]) ->
  io:format("~n");

printLast([H|T]) ->
  io:format("~p", [H]),
  printLast(T).

printRes(A, B, Sum, Carry) ->
  io:format("  "),
  printCar(Carry, "1"),
  io:format("  "),
  printCar(Carry, "-"),
  io:format("  ~p ", [A]),
  io:format("~n+ ~p", [B]),
  io:format("~n"),
  printLast(Sum, start).
    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%                       Tests                      %%%%%%%%%                                  
%%%%%%%%%                                                  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

listify_test() ->
  ?assertEqual([1,2,3,4,5,6], listify(123456)),
  ?assertEqual([1], listify(1)),
  ?assertEqual([1,2], listify(12)).

zeros_test() ->
  ?assertEqual([0,0,0,1,2,3,4,5,6], zeros([1,2,3,4,5,6], 9)),
  ?assertEqual([1,2,3,4,5,6], zeros([1,2,3,4,5,6], 6)),
  ?assertEqual([0,0,0], zeros([], 3)).

tuplemaker_test() ->
  A = {[1,2,3,4,5,6,0,0,0], [0,0,0,0,0,1,2,3,4]},
  B = {[], []},
  C = {[1], [1]},
  D = tupleMaker([1,2,3,4,5,6,0,0,0], [1,2,3,4]),
  E = tupleMaker([], []),
  F = tupleMaker([1], [1]),

  ?assertEqual(A, D),
  ?assertEqual(B, E),
  ?assertEqual(C, F).

makeArgs_test() ->
  ?assertEqual([{[2,1],[2,1]},{[4,3],[4,3]},{[6,5],[6,5]},{[8,7],[8,7]}], makeArgs([1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8])),
  ?assertEqual([{[1],[5]},{[2],[6]},{[3],[7]},{[4],[8]}], makeArgs([1,2,3,4],[5,6,7,8])),
  ?assertEqual([{[1],[5]},{[2],[6]},{[3],[7]},{[4], [8]},{[0], [9]}], makeArgs([1,2,3,4,0],[5,6,7,8,9])).

crunchNum_test() ->
  ?assertEqual({5, 0}, crunchNum(2,3,0, 10)),
  ?assertEqual({5, 1}, crunchNum(6,9,0, 10)),
  ?assertEqual({6, 0}, crunchNum(2,3,1, 10)),
  ?assertEqual({0, 1}, crunchNum(1,1,0, 2)),
  ?assertEqual({1, 0}, crunchNum(1,0,0, 2)).

go_test() ->
  ?assertEqual({[0,2,4,6,9,1,3,5,6],[0,0,0,0,1,1,1,1]}, go(makeArgs([1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8]), none, 10, self())),
  ?assertEqual({[1,8,2,4,6,9,1,3,5,6],[1,0,0,0,0,1,1,1,1]}, go(makeArgs([9,1,2,3,4,5,6,7,8],[9,1,2,3,4,5,6,7,8]), none, 10, self())),
  ?assertEqual({[0,2,4,6,8],[0,0,0,0]}, go(makeArgs([1,2,3,4],[1,2,3,4]), none, 10, self())),
  ?assertEqual({[0,2,4],[0,0]}, go(makeArgs([1,2],[1,2]), none, 10, self())),
  ?assertEqual({[0,2,5,4],[0,0,1]}, go(makeArgs([1,2,5],[1,2,9]), none, 10, self())),
  ?assertEqual({[1,0,0,1],[1,0,0]}, go(makeArgs([1,0,1],[1,0,0]), none, 2, self())),
  ?assertEqual({[1,0,1,1],[1,0,0]}, go(makeArgs([1,1,1],[1,0,0]), none, 2, self())),
  ?assertEqual({[1,1,1,1,0,1,0,1,1],[1,1,1,1,0,0,0,0]}, go(makeArgs([1,1,1,1,0,0,1,0],[1,1,1,1,1,0,0,1]), none, 2, self())),
  ?assertEqual({[1,1,1,1,0,1,0,1],[1,1,1,1,0,0,0]}, go(makeArgs([1,1,1,1,0,0,1],[1,1,1,1,1,0,0]), none, 2, self())).

goSleep_test() ->
  ?assertEqual({[0,2,4,6,9,1,3,5,6],[0,0,0,0,1,1,1,1]}, go(makeArgs([1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8]), {200, 2000}, 10, self())),
  ?assertEqual({[1,8,2,4,6,9,1,3,5,6],[1,0,0,0,0,1,1,1,1]}, go(makeArgs([9,1,2,3,4,5,6,7,8],[9,1,2,3,4,5,6,7,8]), {300, 500}, 10, self())).