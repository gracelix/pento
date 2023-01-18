defmodule PentoWeb.SearchLive do
  use PentoWeb, :live_view
  alias Pento.Search
  alias Pento.Search.SearchTerm
  alias Pento.Catalog.Product

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_search()
     |> assign_changeset()
     |> assign(:products, [])}
  end

  def assign_search(socket) do
    socket |> assign(:search_term, %SearchTerm{})
  end

  def assign_changeset(%{assigns: %{search_term: search_term}} = socket) do
    socket |> assign(:changeset, Search.change_sku(search_term))
  end

  # handle validate event: pass in form param (search term)
  def handle_event(
        "validate",
        %{"search_term" => search_term_params},
        %{assigns: %{search_term: search_term}} = socket
      ) do
    changeset =
      search_term |> Search.change_sku(search_term_params) |> Map.put(:action, :validate)

    IO.inspect(search_term_params, label: "search term params")
    IO.inspect(search_term, label: "search_term")

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event(
        "save",
        %{"search_term" => search_term_params},
        socket
      ) do
    IO.inspect(search_term_params["sku"], label: "search term params")

    if socket.assigns.changeset.valid? do
      products = Search.get_product_by_sku(search_term_params["sku"])
      IO.inspect(products, label: "products")


      # GET A LIST OF PRODUCTS
      case products do
        [] -> {:noreply, socket |> put_flash(:error, "Cannot find products")}
        [%Product{} | _rest] = products -> {:noreply, socket |> assign(:products, products)}
      end
    else
      {:noreply,
      socket
      |> assign(changeset: socket.assigns.changeset)
      |> put_flash(:error, "Please enter a valid SKU")}
    end
  end
end

# GET ONE PRODUCT
# case product do
#   nil ->
#     {:noreply, socket |> put_flash(:error, "Cannot find product")}

#   %Product{} = product ->
#     # assign result from search.getproductbysku to :product

#     IO.inspect(socket.assigns.product, label: "product found")
#     {:noreply, socket |> assign(:product, product)}
# end
