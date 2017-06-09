-module(producer).
-export([start/3, produce/3]).

start(Workers, _, _) when Workers =< 0 ->
  workers_running;

%%% Cria N processos recursivamente executando a função produce.
start(Workers, Interval, Dest) ->
  spawn_link(producer, produce, [Dest, Interval, 0]),
  start(Workers - 1, Interval, Dest).

%%% Envia mensagens para o loadbalancer a cada X ms recursivamente.
produce(Dest, Interval, Count) ->
  timer:sleep(Interval),
  Val = pid_to_list(self()) ++ " " ++ integer_to_list(Count) 
                            ++ " " ++ random_string(5, "abcdefghihklnm"),
  Dest ! Val,
  produce(Dest, Interval, Count + 1).

%% Gera uma string aleatória
random_string(Length, AllowedChars) ->
    lists:foldl(fun(_, Acc) ->
      [lists:nth(rand:uniform(length(AllowedChars)),
                                   AllowedChars) | Acc]
                end, [], lists:seq(1, Length)).
