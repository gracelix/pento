defmodule Pento.Survey.Demographic.Query do
  import Ecto.Query
  alias Pento.Survey.Demographic

  # base/0: constructor
  # provide a common way to build the foundation for all Demographic queries
  def base do
    Demographic
  end

  # reducer: takes in user_id and transforms the initial query with an additional 'where' clause
  # for every demographic, make sure user ID = demographic's user_id field
  def for_user(query \\ base(), user) do
    query |> where([d], d.user_id == ^user.id)
  end
end
