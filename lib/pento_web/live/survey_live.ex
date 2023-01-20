defmodule PentoWeb.SurveyLive do
  use PentoWeb, :live_view
  #  allows us to call the function component from the survey_live HEEx template
  # alias __MODULE__.Component
  alias PentoWeb.DemographicLive
  alias Pento.Survey

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_demographics()}
  end

  defp assign_demographics(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :demographic, Survey.get_demographic_by_user(current_user))
  end
end
