-module(loadbalancer).

-export([start/1, accept/1, register_consumers/1]).

start(Consumers) ->
  Pid = spawn_link(loadbalancer, accept, [Consumers]),
  register(load_balancer, Pid),
  Pid.

%% Recebe mensagens dos produtores, e envia para o consumidor
%% com menos mensagens na mailbox
%% Também aceita novos consumidores assincronamente
accept(Consumers) ->
  receive
    {register_consumers, Pids} ->
      accept(Consumers ++ Pids);
    Val ->
      balance(Consumers) ! Val,
      accept(Consumers)
  end.

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

%% Função externa que registra novos consumidores assincronamente
register_consumers(PidsStr) ->
  Pids = [list_to_pid(I) || I <- PidsStr],
  whereis(load_balancer) ! {register_consumers, Pids}.
