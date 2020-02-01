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
  pubsub: [name: MyTube.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
