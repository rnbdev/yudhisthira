# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :yudhisthira, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:yudhisthira, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :yudhisthira, authentication_endpoint: "/authenticate"
config :yudhisthira, admin_endpoint: "/admin"
config :yudhisthira, secrets_endpoint: "/secrets"
config :yudhisthira, peers_endpoint: "/peers"
config :yudhisthira, smp_mod: 2410312426921032588552076022197566074856950548502459942654116941958108831682612228890093858261341614673227141477904012196503648957050582631942730706805009223062734745341073406696246014589361659774041027169249453200378729434170325843778659198143763193776859869524088940195577346119843545301547043747207749969763750084308926339295559968882457872412993810129130294592999947926365264059284647209730384947211681434464714438488520940127459844288859336526896320919633919
config :yudhisthira, authentication_interval: 10_000
config :yudhisthira, session_lifespan: 20_000
config :yudhisthira, admin_port: 3000
config :yudhisthira, embedded_secret: "Embedded-Secret"

config :yudhisthira, admin_port: 5001
config :yudhisthira, admin_port_range: 100
config :yudhisthira, admin_port_diff: 1000

config :yudhisthira, header_prefix: "X-Yudhisthira"
config :yudhisthira, hostname_header: "Hostname"
config :yudhisthira, hostport_header: "Host-Port"
config :yudhisthira, hostid_header: "Id"
config :yudhisthira, session_header: "Session-Id"
config :yudhisthira, auth_data_header: "Auth-Data"
config :yudhisthira, secret_key_header: "Secret-Key"
config :yudhisthira, auth_header: "Authy"

# Overridable from cmd line
config :yudhisthira, http_port: 4001
config :yudhisthira, host_port: 4001
config :yudhisthira, http_host: "127.0.0.1"
config :yudhisthira, ssl_enabled: false
