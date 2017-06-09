# Producer Consumer problem in erlang
The program consists of many producers and consumers messaging each other concurrently through a simple load balancer.

## Building
`erl`

`c(consumer), c(producer), c(loadbalancer), c(main).`

## Running
`main:start({producer, 4, 1000}, {consumer, 2, 1000}).`

Where: `{producer, ProducerWorkers, ProducerInterval},
 {consumer, ConsumerWorkers, ConsumerInterval})`

The program can be stopped with `main:stop().`
