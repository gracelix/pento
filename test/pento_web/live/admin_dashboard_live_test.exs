defmodule PentoWeb.AdminDashboardLiveTest do
  # allows us to route to live views using the test connection
  # gives our tests access to a context map with a key of :conn pointing to a value of the test connection
  use PentoWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Pento.{Accounts, Survey, Catalog}

  # module attributes with test data
  @create_product_attrs %{
    description: "test description",
    name: "Test Game",
    sku: 42,
    unit_price: 120.5
  }

  @create_demographic_attrs %{
    gender: "female",
    year_of_birth: DateTime.utc_now().year - 15, # 18 and under
    education_level: "bachelor's degree"
  }

  @create_demographic_over_18_attrs %{
    gender: "female",
    year_of_birth: DateTime.utc_now().year - 30,
    education_level: "bachelor's degree"
  }

  @create_user_attrs %{
    email: "test@test.com",
    password: "passwordpassword",
    username: "user1"
  }
  @create_user2_attrs %{
    email: "test2@test.com",
    password: "passwordpassword",
    username: "user2"
  }
  @create_user3_attrs %{
    email: "test3@test.com",
    password: "passwordpassword",
    username: "user3"
  }

  # test fixtures uses module attributes to create User, Demographic, Product and Rating records
  defp product_fixture do
    {:ok, product} = Catalog.create_product(@create_product_attrs)
    product
  end

  defp user_fixture(attrs \\ @create_user_attrs) do
    {:ok, user} = Accounts.register_user(attrs)
    user
  end

  defp demographic_fixture(user, attrs \\ @create_demographic_attrs) do
    attrs = attrs |> Map.merge(%{user_id: user.id})
    {:ok, demographic} = Survey.create_demographic(attrs)
    demographic
  end

  defp rating_fixture(stars, user, product) do
    {:ok, rating} = Survey.create_rating(%{stars: stars, user_id: user.id, product_id: product.id})
    rating
  end

  # helpers that call on the fixtures and return the newly created records
  defp create_product(_) do
    product = product_fixture()
    %{product: product}
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  defp create_rating(stars, user, product) do
    rating = rating_fixture(stars, user, product)
    %{rating: rating}
  end

  defp create_demographic(user, attrs \\ @create_demographic_attrs) do
    demographic = demographic_fixture(user, attrs)
    %{demographic: demographic}
  end

  ########################

  # the actual unit tests ("describe" function groups a block of tests)
  describe "survey results" do
    # visiting the /admin-dashboard route requires an authenticated user
    setup [:register_and_log_in_user, :create_product, :create_user]

    setup %{user: user, product: product} do
      create_demographic(user)
      create_rating(2, user, product)

      user2 = user_fixture(@create_user2_attrs)
      create_demographic(user2, @create_demographic_over_18_attrs)
      create_rating(3, user2, product)
      :ok
    end

    test "it filters by age group", %{conn: conn} do
      # 1. mount and render live view, 2. find age group filter and select age group, 3. assert that the re-rendered chart has correct data
      {:ok, view, _html} = live(conn, "/admin-dashboard")

      # html = view
      # |> open_browser() # inspect a browser page at a given point
      # |> element("#age-group-form") # components run in their parent's process
      # |> render_change(%{"age_group_filter" => "18 and under"}) # simulate user interactions by triggering phx-change event

      params = %{"age_group_filter" => "18 and under"}
      assert view |> element("#age-group-form") |> render_change(params) =~ "<title>2.00</title>"
    end
  end
end
