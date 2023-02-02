defmodule PentoWeb.Admin.UserSurveyLive do
  use PentoWeb, :live_component
  alias PentoWeb.Presence

  def update(_assigns, socket) do
    {:ok, socket |> assign_user_survey_count() |> assign_user_survey()}
  end

  def assign_user_survey_count(socket) do
    assign(socket, :user_survey_count, Presence.count_survey_takers())
  end

  def assign_user_survey(socket) do
    assign(socket, :user_survey_list, Presence.list_survey_takers())
  end
end
