-module(python_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").

all() ->
    [
    common,
    ssl,
    connect_options
    ].

init_per_testcase(_, Config) ->
    Config1 = rabbit_ct_helpers:set_config(Config,
                                           [{rmq_certspwd, "bunnychow"},
                                            {rmq_nodename_suffix, ?MODULE}]),
    rabbit_ct_helpers:log_environment(),
    Config2 = rabbit_ct_helpers:run_setup_steps(
        Config1,
        rabbit_ct_broker_helpers:setup_steps()),
    DataDir = ?config(data_dir, Config2),
    PikaDir = filename:join([DataDir, "deps", "pika"]),
    StomppyDir = filename:join([DataDir, "deps", "stomppy"]),
    rabbit_ct_helpers:make(Config2, PikaDir, []),
    rabbit_ct_helpers:make(Config2, StomppyDir, []),
    Config2.

end_per_testcase(_, Config) ->
    rabbit_ct_helpers:run_teardown_steps(Config).


common(Config) ->
    run(Config, filename:join("src", "test.py")).

connect_options(Config) ->
    run(Config, filename:join("src", "test_connect_options.py")).

ssl(Config) ->
    run(Config, filename:join("src", "test_ssl.py")).

run(Config, Test) ->
    DataDir = ?config(data_dir, Config),
    CertsDir = rabbit_ct_helpers:get_config(Config, rmq_certsdir),
    StompPort = rabbit_ct_broker_helpers:get_node_config(Config, 0, tcp_port_stomp),
    StompPortTls = rabbit_ct_broker_helpers:get_node_config(Config, 0, tcp_port_stomp_tls),
    AmqpPort = rabbit_ct_broker_helpers:get_node_config(Config, 0, tcp_port_amqp),
    NodeName = rabbit_ct_broker_helpers:get_node_config(Config, 0, nodename),
    PythonPath = os:getenv("PYTHONPATH"),
    os:putenv("PYTHONPATH", filename:join([DataDir, "deps", "pika","pika"])
                            ++":"++
                            filename:join([DataDir, "deps", "stomppy", "stomppy"])
                            ++ ":" ++
                            PythonPath),
    os:putenv("AMQP_PORT", integer_to_list(AmqpPort)),
    os:putenv("STOMP_PORT", integer_to_list(StompPort)),
    os:putenv("STOMP_PORT_TLS", integer_to_list(StompPortTls)),
    os:putenv("RABBITMQ_NODENAME", atom_to_list(NodeName)),
    os:putenv("SSL_CERTS_PATH", CertsDir),
    {ok, _} = rabbit_ct_helpers:exec([filename:join(DataDir, Test)]).


cur_dir() ->
    {Src, _} = filename:find_src(?MODULE),
    filename:dirname(Src).
