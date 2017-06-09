-module(watcher).

-export([start/1, stop/0]).

%% Exibe o tamanho da mailbox de cada processo especificado
start(Pids) ->
  register(watcher, self()),
  watch(Pids).

watch(Pids) ->
  timer:sleep(50),
  io:format(os:cmd(clear)),
  lists:foreach(fun(Pid) ->
                  Len = process_info(list_to_pid(Pid), message_queue_len),
                  io:format("~s -> ~w~n", [Pid, Len])
                end, Pids),
  watch(Pids).

stop() ->
  exit(whereis(watcher), stop).
