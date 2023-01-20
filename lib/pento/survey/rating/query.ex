defmodule Pento.Survey.Rating.Query do
  import Ecto.Query
  alias Pento.Survey.Rating

  # constructor
  def base do
    Rating
  end

  # reducer: for every rating, make sure user ID = rating's user_id field
  def preload_user(user) do
    base() |> for_user(user)
  end

  def for_user(query, user) do
    query |> where([r], r.user_id == ^user.id)
  end
end
