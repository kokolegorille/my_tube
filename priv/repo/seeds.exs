# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MyTube.Repo.insert!(%MyTube.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MyTube.Accounts

# Create admin
{:ok, _admin} = Accounts.create_user(%{
  name: "admin",
  email: "admin@example.local",
  password: "secret",
  roles: ["Admin"]
  })
