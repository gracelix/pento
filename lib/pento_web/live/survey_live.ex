defmodule PentoWeb.SurveyLive do
  use PentoWeb, :live_view
  # allows us to call the function component from the survey_live HEEx template
  # alias __MODULE__.Component
  alias PentoWeb.DemographicLive
  alias Pento.Survey
  alias PentoWeb.DemographicLive.Form
  alias PentoWeb.RatingLive
  alias Pento.Catalog

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_demographics() |> assign_products()}
  end

  def handle_info({:created_demographic, demographic}, socket) do
    {:noreply, handle_demographic_created(socket, demographic)}
  end

  def handle_info({:created_rating, product, product_index}, socket) do
    {:noreply, handle_rating_created(socket, product, product_index)}
  end

  # reducers
  def handle_demographic_created(socket, demographic) do
    socket
    |> put_flash(:info, "Demographic created successfully")
    |> assign(:demographic, demographic)
  end

  def handle_rating_created(
        %{assigns: %{products: products}} = socket,
        updated_product,
        product_index
      ) do
    socket
    |> put_flash(:info, "Rating submitted succesfully")
    |> assign(:products, List.replace_at(products, product_index, updated_product))
  end

  def assign_demographics(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :demographic, Survey.get_demographic_by_user(current_user))
  end

  def assign_products(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :products, list_products(current_user))
  end

  defp list_products(user) do
    Catalog.list_products_with_user_rating(user)
  end
end
