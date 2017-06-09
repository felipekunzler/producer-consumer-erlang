-module(main).
-export([start/2, stop/0]).

start({producer, ProducerWorkers, ProducerInterval},
	  {consumer, ConsumerWorkers, ConsumerInterval}) ->

  register(main, self()),
  ConsumerPids = consumer:start(ConsumerWorkers, ConsumerInterval),
  LoadbalancerPid = loadbalancer:start(ConsumerPids),
  producer:start(ProducerWorkers, ProducerInterval, LoadbalancerPid),
  {consumers_running, [pid_to_list(I) || I <- ConsumerPids]}.

stop() ->
  % Para o processo principal e seus links (producers, consumers e loadbalancer)
  exit(whereis(main), stop).
