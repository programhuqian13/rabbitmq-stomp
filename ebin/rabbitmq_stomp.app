{application, rabbitmq_stomp,
 [{description, "Embedded Rabbit Stomp Adapter"},
  {vsn, "%%VSN%%"},
  {modules, [
            rabbit_stomp,
            rabbit_stomp_client_sup,
            rabbit_stomp_frame,
            rabbit_stomp_processor,
            rabbit_stomp_reader,
            rabbit_stomp_sup,
            rabbit_stomp_util
  ]},
  {registered, []},
  {mod, {rabbit_stomp, []}},
  {env, [{tcp_listeners, [61613]},
         {tcp_listen_options, [binary,
                               {packet,    raw},
                               {reuseaddr, true},
                               {backlog,   128},
                               {nodelay,   true}]}]},
  {applications, [kernel, stdlib, rabbit]}]}.