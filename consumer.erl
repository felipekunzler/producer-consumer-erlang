-module(consumer).
-export([start/2, consume/1]).

start(Workers, Interval) ->
  start(Workers, Interval, []).

start(Workers, _, Pids) when Workers =< 0 ->
  io:format("~p~n", [{consumers_running, [pid_to_list(I) || I <- Pids]}]),
  Pids;

%% Cria N processos recursivamente e armazena o Pid na lista Pids,
%% a list Pids será retornada quando todos os N processos forem criados.
start(Workers, Interval, Pids) ->
  Pid = spawn_link(consumer, consume, [Interval]),
  start(Workers - 1, Interval, [Pid | Pids]).

%% Recebe e processa mensagens recursivamente.
consume(Interval) ->
  receive
    Val ->
      timer:sleep(Interval),
      Hash = md5(Val) ++ " " ++ pid_to_list(self()),
      io:format("~s -> ~s~n", [Val, Hash])
  end,
  consume(Interval).

%% Gera o hash md5 de uma string
md5(Val) ->
  <<X:128/big-unsigned-integer>> = erlang:md5(Val),
  lists:flatten(io_lib:format("~32.16.0b", [X])).
