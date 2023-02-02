defmodule PentoWeb.Presence do
  use Phoenix.Presence, otp_app: :pento, pubsub_server: Pento.PubSub

  alias PentoWeb.Presence
  @user_activity_topic "user_activity"
  @user_survey_topic "user_survey_count"

  def track_user(pid, product, user_email) do
    Presence.track(
      pid, #  PID of the LiveView process
      @user_activity_topic,
      product.name,
      %{users: [%{email: user_email}]}
    )
  end

  def list_products_and_users do
    Presence.list(@user_activity_topic) |> Enum.map(&extract_product_with_users/1)
  end

  defp extract_product_with_users({product_name, %{metas: metas}}) do
    {product_name, users_from_metas_list(metas)}
  end

  ###########################

  def track_survey_takers(pid, user_id) do
    Presence.track(pid, @user_survey_topic, "survey-form", %{users: [%{user_id: user_id}]})
  end

  def list_survey_takers do
    Presence.list(@user_survey_topic)
    |> Enum.map(&extract_survey_takers/1)
    |> count_survey_takers()
  end

  defp extract_survey_takers({_key, %{metas: metas}}) do
    users_from_metas_list(metas)
  end

  defp count_survey_takers(user_ids) do
    if Enum.any?(user_ids) do
      user_ids |> List.first() |> Enum.count()
    else
      0
    end
  end

  ###########################

  defp users_from_metas_list(metas_list) do
    Enum.map(metas_list, &users_from_meta_map/1) |> List.flatten() |> Enum.uniq()
  end

  defp users_from_meta_map(meta_map) do
    get_in(meta_map, [:users])
  end
end
