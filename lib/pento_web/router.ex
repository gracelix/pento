defmodule PentoWeb.Router do
  use PentoWeb, :router

  import PentoWeb.UserAuth

  pipeline :browser do
    # accept only html requests
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {PentoWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    #  if user is logged in, fetch_current_user/2 function plug will add a key in assigns called current_user.
    plug(:fetch_current_user)
    # Now, whenever a user logs in, any code that handles routes tied to the browser pipeline
    # will have access to the current_user in conn.assigns.current_user
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # Other scopes may use custom stacks.
  # scope "/api", PentoWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: PentoWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", PentoWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])
    get("/", PageController, :index)

    # if user not logged in, can go here
    get("/users/register", UserRegistrationController, :new)
    post("/users/register", UserRegistrationController, :create)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
    put("/users/reset_password/:token", UserResetPasswordController, :update)
  end

  scope "/", PentoWeb do
    # only logged-in users allowed here
    # no need to force page reload for redirection within this block
    pipe_through([:browser, :require_authenticated_user])

    live_session :default, on_mount: PentoWeb.UserAuthLive do
      #  use the browser pipeline and call the require_authenticated_user plug
      live("/guess", WrongLive)
      live "/promo", PromoLive
      live("/search", SearchLive)

      live("/products", ProductLive.Index, :index)
      live("/products/new", ProductLive.Index, :new)
      live("/products/:id/edit", ProductLive.Index, :edit)

      live("/products/:id", ProductLive.Show, :show)
      live("/products/:id/show/edit", ProductLive.Show, :edit)

      live "/faqs", FaqLive.Index, :index
      live "/faqs/new", FaqLive.Index, :new
      live "/faqs/:id/edit", FaqLive.Index, :edit

      live "/faqs/:id", FaqLive.Show, :show
      live "/faqs/:id/show/edit", FaqLive.Show, :edit

      get("/users/settings", UserSettingsController, :edit)
      put("/users/settings", UserSettingsController, :update)
      get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)
    end
  end

  # "/" -> applies to all routes that start with /
  scope "/", PentoWeb do
    # every matching req in this block will go through all the plugs in the :browser pipeline
    pipe_through(:browser)

    # every route starts with 1) route type, 2) URL pattern, 3) module, 4) options
    # get("/", PageController, :index)
    # live "/guess", WrongLive

    delete("/users/log_out", UserSessionController, :delete)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :edit)
    post("/users/confirm/:token", UserConfirmationController, :update)
  end
end
