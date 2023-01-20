defmodule Pento.Catalog.Product.Query do
  import Ecto.Query
  alias Pento.Catalog.Product
  alias Pento.Survey.Rating

  # constructor
  def base, do: Product

  # reducer: for every product, (1) preload the ratings of that product
  def with_user_ratings(user) do
    base() |> preload_user_ratings(user)
  end

  def preload_user_ratings(query, user) do
    # (2) for every rating, get the user who left this rating
    ratings_query = Rating.Query.preload_user(user)

    # (3) preload ratings' associations (ie. user)
    query |> preload(ratings: ^ratings_query)
  end
end
