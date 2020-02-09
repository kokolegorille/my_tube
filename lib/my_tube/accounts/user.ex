defmodule MyTube.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyTube.Core
  alias Core.Event

  @roles ~w(Admin SuperEditor Editor Contributor)

  schema "users" do
    has_many(:events, Event)

    # Likes and views
    many_to_many :liked_events, Event, join_through: "likes", on_replace: :delete
    many_to_many :viewed_events, Event, join_through: "views", on_replace: :delete

    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    # Embed roles
    field :roles, {:array, :string}, virtual: true, default: []
    field :roles_mask, :integer, default: 0
    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(name email)a
  @optional_fields ~w(roles)a
  @registration_fields ~w(password)a

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 1, max: 32)
    |> validate_format(:email, ~r/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
    |> unique_constraint(:name, message: "Name already taken")
    |> unique_constraint(:email, message: "Email already taken")
    |> put_roles_mask()
  end

  @doc false
  def registration_changeset(user, attrs \\ %{}) do
    user
    |> changeset(attrs)
    |> cast(attrs, @registration_fields)
    |> validate_required(@registration_fields)
    |> validate_length(:password, min: 6, max: 32)
    |> put_pass_hash()
  end

  # Roles helpers
  def allowed_roles, do: @roles

  def has_role?(user, role) do
    user.roles_mask
    |> roles_from_mask()
    |> Enum.member?(role)
  end

  use Bitwise, only_operators: true

  # Translation from ruby code
  # ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  #
  def roles_from_mask(mask) do
    Enum.reject(@roles, fn r ->
      ((mask || 0) &&& trunc(:math.pow(2, role_index(r)))) == 0
    end)
  end

  # Translation from ruby code
  # self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  #
  def mask_from_roles(roles) when is_list(roles) do
    roles
    |> intersect(@roles)
    |> Enum.reduce(0, fn r, acc -> acc + trunc(:math.pow(2, role_index(r))) end)
  end

  def role_index(role) do
    Enum.find_index(@roles, & &1 == role)
  end

  defp intersect(list1, list2) do
    list3 = list1 -- list2
    list1 -- list3
  end

  # PRIVATE

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end
  defp put_pass_hash(changeset), do: changeset

  defp put_roles_mask(%Ecto.Changeset{valid?: true, changes: %{roles: roles}} = changeset) do
    put_change(changeset, :roles_mask, mask_from_roles(roles))
  end
  defp put_roles_mask(changeset), do: changeset
end
