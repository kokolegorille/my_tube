defmodule MyTube.Viewing do
  @moduledoc """
  The Viewing context.
  It is a CORE sub module.
  This module holds logic for event viewing.
  """

  import Ecto.Query, warn: false

  alias MyTube.{Accounts, Core, Repo}
  alias Core.Event

  def view_query(user, event) do
    user = if Ecto.assoc_loaded?(user.viewed_events),
      do: user,
      else: Repo.preload(user, :viewed_events)

    event_ids = user.viewed_events |> Enum.map(& &1.id)
    if Enum.member?(event_ids, event.id) do
      :error
    else
      # Counter cache
      # https://hexdocs.pm/ecto/Ecto.Changeset.html#prepare_changes/2
      user
      |> Accounts.change_user()
      |> Ecto.Changeset.put_assoc(:viewed_events, [event | user.viewed_events])
      |> Ecto.Changeset.prepare_changes(fn changeset ->
        query = from Event, where: [id: ^(event.id)]
        changeset.repo.update_all(query, inc: [views_count: 1])
        changeset
      end)
    end
  end

  def view(user, event) do
    case view_query(user, event) do
      :error -> :error
      changeset -> Repo.update(changeset)
    end
  end
end
