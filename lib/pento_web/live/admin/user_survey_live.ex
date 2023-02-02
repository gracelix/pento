defmodule PentoWeb.Admin.UserSurveyLive do
  use PentoWeb, :live_component
  alias PentoWeb.Presence

  def update(_assigns, socket) do
    {:ok, socket |> assign_user_survey()}
  end

  def assign_user_survey(socket) do
    assign(socket, :user_survey, Presence.list_survey_takers())
  end
end
