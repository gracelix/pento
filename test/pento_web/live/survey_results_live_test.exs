defmodule PentoWeb.SurveyResultsLiveTest do
  #  provides access to the ExUnit testing functions and provides our test
  #  with a connection to the application’s test database
  use Pento.DataCase
  alias PentoWeb.Admin.SurveyResultsLive
  alias Pento.{Accounts, Survey, Catalog}

  # module attributes with test data
  @create_product_attrs %{
    description: "test description",
    name: "Test Game",
    sku: 42,
    unit_price: 120.5
  }

  @create_user_attrs %{
    email: "test@test.com",
    password: "passwordpassword",
    username: "user1"
  }

  @create_user2_attrs %{
    email: "anotherperson@test.com",
    password: "passwordpassword",
    username: "user2"
  }

  @create_demographic_attrs %{
    gender: "female",
    year_of_birth: DateTime.utc_now().year - 15, # 18 and under
    education_level: "bachelor's degree"
  }

  @create_demographic2_attrs %{
    gender: "male",
    year_of_birth: DateTime.utc_now().year - 30,
    education_level: "graduate degree"
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

  defp create_demographic(user) do
    demographic = demographic_fixture(user)
    %{demographic: demographic}
  end

  defp create_socket(_) do
    %{socket: %Phoenix.LiveView.Socket{}}
  end

  defp update_socket(socket, key, value) do
    %{socket | assigns: Map.merge(socket.assigns, Map.new([{key, value}]))}
  end

  defp assert_keys(socket, key, value) do
    assert socket.assigns[key] == value
    socket
  end

  ########################

  # the actual unit tests ("describe" function groups a block of tests)
  # run setup/1 before each test
  # setups build a map by adding to context, and passes it into each test in the describe block
  describe "socket state" do
    # list of atoms, return values to be merged into the context
    setup [:create_user, :create_product, :create_socket]

    setup %{user: user} do
      create_demographic(user)
      user2 = user_fixture(@create_user2_attrs)
      demographic_fixture(user2, @create_demographic2_attrs)
      # return value added to context map
      [user2: user2]
    end

    test "no ratings exists", %{socket: socket} do
      socket =
        socket
        # to call assign_products_with_average_ratings, need to alr have the age group and gender filters in the socket
        |> SurveyResultsLive.assign_age_group_filter()
        |> SurveyResultsLive.assign_gender_filter()
        |> SurveyResultsLive.assign_products_with_average_ratings()

      assert socket.assigns.products_with_average_ratings == [{"Test Game", 0}]
    end

    test "ratings exist", %{socket: socket, product: product, user: user} do
      create_rating(2, user, product)

      socket =
        socket
        |> SurveyResultsLive.assign_age_group_filter()
        |> SurveyResultsLive.assign_gender_filter()
        |> SurveyResultsLive.assign_products_with_average_ratings()

      assert socket.assigns.products_with_average_ratings == [{"Test Game", 2.0}]
    end

    test "ratings are filtered by age group", %{socket: socket, user: user, product: product, user2: user2} do
      create_rating(2, user, product)
      create_rating(3, user2, product)
      # socket = socket |> SurveyResultsLive.assign_age_group_filter()
      # assert socket.assigns.age_group_filter == "all"

      # socket = update_socket(socket, :age_group_filter, "18 and under") |> SurveyResultsLive.assign_age_group_filter()
      # assert socket.assigns.age_group_filter == "18 and under"

      ##### ALTERNATIVELY: creating a test pipeline with the assertion reducer #####
      socket
      |> SurveyResultsLive.assign_age_group_filter()
      |> assert_keys(:age_group_filter, "all")
      |> update_socket(:age_group_filter, "18 and under")
      |> SurveyResultsLive.assign_age_group_filter()
      |> assert_keys(:age_group_filter, "18 and under")
      |> SurveyResultsLive.assign_gender_filter()
      |> SurveyResultsLive.assign_products_with_average_ratings()
      |> assert_keys(:products_with_average_ratings, [{"Test Game", 2.0}])
    end
  end
end
