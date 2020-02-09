defmodule MyTube.Liking do
  @moduledoc """
  The Liking context.
  It is a CORE sub module.
  This module holds logic for event liking.
  """

  import Ecto.Query, warn: false

  alias MyTube.{Accounts, Core, Repo}
  alias Core.Event

  def like_query(user, event) do
    user = if Ecto.assoc_loaded?(user.liked_events),
      do: user,
      else: Repo.preload(user, :liked_events)

    event_ids = user.liked_events |> Enum.map(& &1.id)
    if Enum.member?(event_ids, event.id) do
      :error
    else
      user
      |> Accounts.change_user()
      |> Ecto.Changeset.put_assoc(:liked_events, [event | user.liked_events])
      |> Ecto.Changeset.prepare_changes(fn changeset ->
        query = from Event, where: [id: ^(event.id)]
        changeset.repo.update_all(query, inc: [likes_count: 1])
        changeset
      end)
    end
  end

  def like(user, event) do
    case like_query(user, event) do
      :error -> :error
      changeset -> Repo.update(changeset)
    end
  end

  def unlike_query(user, event) do
    user = if Ecto.assoc_loaded?(user.liked_events),
      do: user,
      else: Repo.preload(user, :liked_events)

    event_ids = user.liked_events |> Enum.map(& &1.id)
    if Enum.member?(event_ids, event.id) do
      events = Enum.reject(user.liked_events, & &1.id == event.id)

      user
      |> Accounts.change_user()
      |> Ecto.Changeset.put_assoc(:liked_events, events)
      |> Ecto.Changeset.prepare_changes(fn changeset ->
        query = from Event, where: [id: ^(event.id)]
        changeset.repo.update_all(query, inc: [likes_count: -1])
        changeset
      end)
    else
      :error
    end
  end

  def unlike(user, event) do
    case unlike_query(user, event) do
      :error -> :error
      changeset -> Repo.update(changeset)
    end
  end

  def toggle_like_query(user, event) do
    user = if Ecto.assoc_loaded?(user.liked_events),
      do: user,
      else: Repo.preload(user, :liked_events)

    event_ids = user.liked_events |> Enum.map(& &1.id)
    {inc_value, events} = if Enum.member?(event_ids, event.id),
      do: {-1, Enum.reject(user.liked_events, & &1.id == event.id)},
      else: {1, [event | user.liked_events]}

    user
    |> Accounts.change_user()
    |> Ecto.Changeset.put_assoc(:liked_events, events)
    |> Ecto.Changeset.prepare_changes(fn changeset ->
      query = from Event, where: [id: ^(event.id)]
      changeset.repo.update_all(query, inc: [likes_count: inc_value])
      changeset
    end)
  end

  def toggle_like(user, event) do
    Repo.update(toggle_like_query(user, event))
  end
end
