defmodule Pento.Survey.Rating do
  use Ecto.Schema
  import Ecto.Changeset
  alias Pento.Accounts.User
  alias Pento.Catalog.Product

  schema "ratings" do
    field :stars, :integer
    # replace
    # field :user_id, :id
    # field :product_id, :id
    # with
    belongs_to :user, User
    belongs_to :product, Product

    # so now we have access to user and product fields and the user_id and product_id fields on the Rating struct

    timestamps()
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:stars, :user_id, :product_id])
    |> validate_required([:stars, :user_id, :product_id])
    |> validate_inclusion(:stars, 1..5) # range of possible values 1 to 5
    |> unique_constraint(:product_id, name: :index_ratings_on_user_product)
  end
end
