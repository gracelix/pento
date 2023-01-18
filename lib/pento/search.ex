defmodule Pento.Search do
  import Ecto.Query, warn: false
  alias Pento.Search.SearchTerm
  alias Pento.Catalog.Product
  alias Pento.Repo

  def change_sku(%SearchTerm{} = search_term, attrs \\ %{}) do
    SearchTerm.changeset(search_term, attrs)
  end

  def get_product_by_sku(search_term) do
    like = "%#{search_term}%"
    from(p in Product, where: like(fragment("CAST(? AS TEXT)", p.sku), ^like))
    |> Repo.all()
    # Repo.get_by(Product, %{sku: search_term})
  end
end
