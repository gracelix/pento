# schemaless changeset
defmodule Pento.Promo.Recipient do
  defstruct [:first_name, :email]
  @types %{first_name: :string, email: :string}

  import Ecto.Changeset

  def changeset(%__MODULE__{} = user, attrs) do
    {user, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:first_name, :email])
    |> validate_format(:email, ~r/@/)

    # create recipient changesets like this
    # iex> r = %Recipient{}
    # iex> Pento.Promo.Recipient.changeset(r, %{email: "joe@email.com", first_name: "Joe"})
  end
end
