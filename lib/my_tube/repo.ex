defmodule MyTube.Repo do
  use Ecto.Repo,
    otp_app: :my_tube,
    adapter: Ecto.Adapters.Postgres
end
