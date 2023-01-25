defmodule PentoWeb.DemographicLive.Form do
  use PentoWeb, :live_component
  alias Pento.Survey
  alias Pento.Survey.Demographic

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_demographic() |> assign_changeset()}
  end

  # skinny handler -> calls reducer to do the work
  def handle_event("save", %{"demographic" => demographic_params}, socket) do
    IO.puts("Handling 'save' event and saving demographic record...")
    IO.inspect(demographic_params)
    {:noreply, save_demographic(socket, demographic_params)}
  end

  # reducer to save the event
  defp save_demographic(socket, demographic_params) do
    case Survey.create_demographic(demographic_params) do
      {:ok, demographic} ->
        # send a message to the parent live component (SurveyLive)
        send(self(), {:created_demographic, demographic})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  # add an empty demographic struct containing the user_id for the current user
  def assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :demographic, %Demographic{user_id: current_user.id})
  end

  def assign_changeset(%{assigns: %{demographic: demographic}} = socket) do
    assign(socket, :changeset, Survey.change_demographic(demographic))
  end
end
