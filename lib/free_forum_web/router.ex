defmodule FreeForumWeb.Router do
  use FreeForumWeb, :router

  import FreeForumWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FreeForumWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :browser_no_csrf_protection do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FreeForumWeb.Layouts, :root}
    # HACK: Отключим установленную по умолчанию защиту от CSRF атак
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FreeForumWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  ## Authenticated-only resources routes

  scope "/", FreeForumWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/topics", TopicController, except: [:index, :show, :new, :create]
  end

  scope "/", FreeForumWeb do
    pipe_through [:browser_no_csrf_protection, :require_authenticated_user]

    resources "/topics", TopicController, only: [:new, :create]
  end

  ## Public resources routes

  scope "/", FreeForumWeb do
    pipe_through :browser

    live "/topics", Live.Topics
    live "/topics/:topic", Live.Topic
    resources "/topics/:topic/comment", CommentController, only: [:create, :edit, :update, :delete]
  end

  ## Authentication routes

  scope "/", FreeForumWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", FreeForumWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", FreeForumWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:free_forum, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FreeForumWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
