-module(loadbalancer).
-export([start/1, accept/1, watch_start/1, watch_stop/0]).

start(Consumers) ->
  spawn_link(loadbalancer, accept, [Consumers]).

%% Recebe mensagens dos produtores, e envia para o consumidor
%% com menos mensagens na mailbox
accept(Consumers) ->
  receive
    Val ->
      balance(Consumers) ! Val
  end,
  accept(Consumers).

%% Dado uma lista de Pids, retorna aquele com menos mensagens
%% na sua mailbox.
balance(Consumers) ->
  [H | ConsumersReduced] = Consumers,
  Len = process_info(H, message_queue_len),
  balance(ConsumersReduced, H, Len).

balance(Consumers, Consumer, _) when length(Consumers) == 0 ->
  Consumer;

balance(Consumers, Consumer, MinLen) ->
  [H | ConsumersReduced] = Consumers,
  Len = process_info(H, message_queue_len),
  if
    Len < MinLen ->
      balance(ConsumersReduced, H, Len);
    true ->
      balance(ConsumersReduced, Consumer, MinLen)
  end.

%% Função externa que mostra o tamanho da mailbox de cada processo
watch_start(Pids) ->
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

watch_stop() ->
  exit(whereis(watcher), stop).