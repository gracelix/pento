defmodule PentoWeb.RatingLiveTest do
  use PentoWeb.ConnCase

  import Phoenix.LiveViewTest
  alias PentoWeb.RatingLive
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

  @create_demographic_attrs %{
    gender: "female",
    # 18 and under
    year_of_birth: DateTime.utc_now().year - 15,
    education_level: "bachelor's degree"
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
    {:ok, rating} =
      Survey.create_rating(%{stars: stars, user_id: user.id, product_id: product.id})

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

  describe "survey ratings" do
    setup [:register_and_log_in_user, :create_product, :create_user]

    setup %{user: user} do
      create_demographic(user)

      :ok
    end

    test "rating form rendered with no ratings", %{user: user} do
      assert render_component(&RatingLive.Index.products/1, products: [], current_user: user) ==
               "<div class=\"survey-component-container\">\n    <h2> Ratings\n  &#x2713;\n</h2>\n    \n  </div>"
    end

    test "rating details rendered when ratings exist", %{product: product, user: user} do
      %{rating: rating} = create_rating(3, user, product)
      product = %{product | ratings: [rating]}

      assert render_component(&RatingLive.Index.products/1,
               products: [product],
               current_user: user
             ) ==
               "<div class=\"survey-component-container\">\n    <h2> Ratings\n  &#x2713;\n</h2>\n    \n  \n    <div>\n  <h4>\n    Test Game:<br>\n    &#x2605; &#x2605; &#x2605; &#x2606; &#x2606;\n  </h4>\n</div>\n  \n\n  </div>"
    end
  end
end