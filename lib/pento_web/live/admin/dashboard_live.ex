defmodule PentoWeb.Admin.DashboardLive do
  use PentoWeb, :live_view
  alias PentoWeb.Admin.SurveyResultsLive
  alias PentoWeb.Endpoint

  @survey_results_topic "survey_results"

  def mount(_params, _session, socket) do
    # connected?/1 fn -> only call subscribe/1 if the socket is connected (during 2nd mount/3 call)
    if connected?(socket) do
      Endpoint.subscribe(@survey_results_topic)
    end

    {:ok, socket |> assign(:survey_results_component_id, "survey-results")}
  end

  # receive the message broadcasted over thecommon topic and respond
  def handle_info(%{event: "rating_created"}, socket) do
    # use send_update/3 to send message from parent live view to child component asynchronously
    send_update(SurveyResultsLive, id: socket.assigns.survey_results_component_id)
    {:noreply, socket}
  end
end
