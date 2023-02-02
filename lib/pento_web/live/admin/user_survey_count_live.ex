defmodule PentoWeb.Admin.UserSurveyCountLive do
  use PentoWeb, :live_component
  alias PentoWeb.Presence

  def update(_assigns, socket) do
    {:ok, socket |> assign_user_survey_count()}
  end

  def assign_user_survey_count(socket) do
    assign(socket, :user_survey_count, Presence.list_survey_takers())
  end
end
