defmodule PentoWeb.RatingLive.Form do
  use PentoWeb, :live_component
  alias Pento.Survey
  alias Pento.Survey.Rating

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_rating() |> assign_changeset()}
  end

  def handle_event("validate", %{"rating" => rating_params}, socket) do
    changeset =
      socket.assigns.rating
      |> Survey.change_rating(rating_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  # skinny handler -> calls reducer to do the work
  def handle_event("save", %{"rating" => rating_params}, socket) do
    {:noreply, save_rating(socket, rating_params)}
  end

  # reducer to save the event
  def save_rating(
        %{assigns: %{product_index: product_index, product: product}} = socket,
        rating_params
      ) do
    case Survey.create_rating(rating_params) do
      {:ok, rating} ->
        product = %{product | ratings: [rating]}
        send(self(), {:created_rating, product, product_index})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  def assign_rating(%{assigns: %{current_user: current_user, product: product}} = socket) do
    assign(socket, :rating, %Rating{user_id: current_user.id, product_id: product.id})
  end

  def assign_changeset(%{assigns: %{rating: rating}} = socket) do
    assign(socket, :changeset, Survey.change_rating(rating))
  end
end
