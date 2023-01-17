defmodule Pento.Catalog.Product do
  # the use macro injects code from the Ecto.Schema into the current module
  use Ecto.Schema
  import Ecto.Changeset

  # schema function is from Ecto.Schema module
  schema "products" do
    field(:description, :string)
    field(:name, :string)
    field(:sku, :integer)
    field(:unit_price, :float)
    field(:image_upload, :string)

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :unit_price, :sku, :image_upload])
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unique_constraint(:sku)
    |> validate_number(:unit_price, greater_than: 0.0)
  end

  def unit_price_changeset(%{unit_price: up} = product, attrs) do
    product
    # |> IO.inspect(label: "before")
    |> cast(attrs, [:unit_price])
    # |> IO.inspect(label: "after")
    |> validate_number(:unit_price, less_than: up)

    # |> IO.inspect(label: "xxx")
  end
end
