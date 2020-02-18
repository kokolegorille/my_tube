# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :my_tube,
  ecto_repos: [MyTube.Repo]

# Configures the endpoint
config :my_tube, MyTubeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZKLoZ8S/IDDHBicCUpIW7opVlJmKGKc3/CBF1L+XJ9zrqrg2JSHrxTohZSr6IMPJ",
  render_errors: [view: MyTubeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MyTube.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "L+TUlmWe+oP81lUh/VGCP+daxzD/cCZ1"
  ]

# # Configures Elixir's Logger
# config :logger, :console,
#   format: "$time $metadata[$level] $message\n",
#   metadata: [:request_id]

# config :logger,
#   backends: [{LoggerFileBackend, :error_log}]
# config :logger, :error_log,
#   path: "/var/log/my_tube/error.log",
#   level: :error

config :logger,
  backends: [
    {LoggerFileBackend, :info},
    {LoggerFileBackend, :error}
  ]

config :logger, :error,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  path: "my_tube_error.log",
  level: :error

config :logger, :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  path: "my_tube_info.log",
  level: :info


# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Gettext
config :my_tube, MyTubeWeb.Gettext, default_locale: "fr", locales: ~w(en fr)

# Waffle
config :waffle,
  storage: Waffle.Storage.Local
  # default timeout is 15_000
  # There is a timeout for large files
  # But increasin does not solve it...
  # version_timeout: 150_000

# Oban
config :my_tube, Oban,
  repo: MyTube.Repo,
  prune: {:maxlen, 10_000},
  queues: [default: 10, events: 50, media: 20]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
