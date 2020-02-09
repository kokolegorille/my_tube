defmodule MyTube.Core do
  @moduledoc """
  The Core context.
  """

  import Ecto.Query, warn: false
  require Logger

  alias MyTube.{Core, Uploaders, Repo}
  alias Core.Event

  @doc """
  Returns the list of events query.

  ## Examples

      iex> list_events()
      #Ecto.Query<from u0 in LoTube.Core.Event>

  """
  def list_events_query(criteria \\ []) do
    query = from p in Event

    Enum.reduce(criteria, query, fn
      {:limit, limit}, query ->
        from p in query, limit: ^limit

      {:offset, offset}, query ->
        from p in query, offset: ^offset

      {:filter, filters}, query ->
        filter_with(filters, query)

      {:order, order}, query ->
        from p in query, order_by: [{^order, :updated_at}, {^order, :id}]

      {:preload, preloads}, query ->
        from p in query, preload: ^preloads

      arg, query ->
        Logger.info("args is not matched in query #{inspect arg}")
        query
    end)
  end

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events(criteria \\ []) do
    criteria
    |> list_events_query()
    |> Repo.all()
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Gets a single event.

  Returns nil if the Event does not exist.

  ## Examples

      iex> get_event(123)
      %Event{}

      iex> get_event(456)
      nil

  """
  def get_event(id), do: Repo.get(Event, id)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  # def create_event(attrs \\ %{}) do
  #   %Event{}
  #   |> Event.changeset(attrs)
  #   |> Repo.insert()
  # end

  def create_event(creator, attrs \\ %{}) do
    result = Ecto.build_assoc(creator, :events)
    |> Event.changeset(attrs)
    |> Repo.insert()

    case result do
      {:ok, event} ->
        # Build the thumb when event is created
        spawn(fn -> Uploaders.MediaTransformer.create_thumb(event) end)

        result
      {:error, _} ->
        result
    end
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    case Repo.delete(event) do
      {:ok, event} ->
        Uploaders.MediaUploader.rm_storage_dirs(event)
        {:ok, event}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{source: %Event{}}

  """
  def change_event(%Event{} = event) do
    Event.changeset(event, %{})
  end

  ########################################
  ### HELPERS
  ########################################

  defp filter_with(filters, query) do
    Enum.reduce(filters, query, fn
      {:name, name}, query ->
        pattern = "%#{name}%"
        from q in query, where: ilike(q.name, ^pattern)
    end)
  end
end
