defmodule MyTube.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  require Logger

  alias MyTube.{Accounts, Repo}
  alias Accounts.User

  @order_field :name

  defdelegate mask_from_roles(mask), to: User
  defdelegate roles_from_mask(roles), to: User
  defdelegate allowed_roles(), to: User
  defdelegate has_role?(current_user, role), to: User
  defdelegate preload(any, associations), to: Repo

  def is_self_and_last_admin?(current_user, user) do
    admins = list_users_with_role("Admin")
    current_user.id == user.id && length(admins) == 1
  end

  @doc """
  Returns the list of users query.

  ## Examples

      iex> list_users_query()
      #Ecto.Query<from u0 in CmsApi.Accounts.User>

  """

  def list_users_query(criteria \\ []) do
    query = from p in User

    Enum.reduce(criteria, query, fn
      {:limit, limit}, query ->
        from p in query, limit: ^limit

      {:offset, offset}, query ->
        from p in query, offset: ^offset

      {:filter, filters}, query ->
        filter_with(filters, query)

      {:order, order}, query ->
        from p in query, order_by: [{^order, ^@order_field}]

      {:preload, preloads}, query ->
        from p in query, preload: ^preloads

      arg, query ->
        Logger.info("args is not matched in query #{inspect arg}")
        query
    end)
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(criteria \\ []) do
    criteria
    |> list_users_query()
    |> Repo.all()
  end

  @doc """
  Returns the list of users with a given role query.

  ## Examples

    iex> list_users_with_role_query("Admin")
    #Ecto.Query<from u0 in CmsApi.Accounts.User>

  """
  # Translation from Ruby
  # where("(roles_mask & #{ 2**ROLES.index(role.to_s) }) > 0")
  def list_users_with_role_query(role) do
    criteria = trunc(:math.pow(2, User.role_index(role)))
    from u in User, where: fragment("roles_mask & ? > 0", ^criteria)
  end

  @doc """
  Returns the list of users with a given role.

  ## Examples

      iex> list_users_with_role("Admin")
      [%User{}, ...]

  """
  def list_users_with_role(role) do
    role
    |> list_users_with_role_query
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user by name

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user_by_name("good_value")
      %User{}

      iex> get_user_by_name("bad_value")
      nil

  """
  def get_user_by_name(nil), do: nil
  def get_user_by_name(name), do: Repo.get_by(User, name: name)

  @doc """
  Gets a single user by email

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user_by_email("good_value@example.com")
      %User{}

      iex> get_user_by_email("bad_value@example.com")
      nil

  """
  def get_user_by_email(nil), do: nil
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def registration_change_user(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  ########################################
  ### Authentication
  ########################################

  def authenticate(name, password),
    do: authenticate(%{"name" => name, "password" => password})

  def authenticate(%{name: name, password: password}),
    do: authenticate(%{"name" => name, "password" => password})

  def authenticate(%{"name" => name, "password" => password}) do
    with %User{} = user <- get_user_by_name(name),
        {:ok, _} <- check_password(user, password) do
      {:ok, user}
    else
      _ -> {:error, :unauthorized}
    end
  end

  def authenticate(_), do: {:error, :unauthorized}

  defp check_password(user, password),
    do: Argon2.check_pass(user, password)

  ########################################
  ### HELPERS
  ########################################

  defp filter_with(filters, query) do
    Enum.reduce(filters, query, fn
      {:name, name}, query ->
        pattern = "%#{name}%"
        from q in query, where: ilike(q.name, ^pattern)

      arg, query ->
        Logger.info("args is not matched in query #{inspect arg}")
        query
    end)
  end
end
