defmodule FreeForumWeb.UserSessionController do
  use FreeForumWeb, :controller

  alias FreeForum.Accounts
  alias FreeForumWeb.UserAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Добро пожаловать, #{user.username}!")
      |> UserAuth.log_in_user(user, user_params)
    else
      render(conn, :new, error_message: "Неверный адрес электронной почты или пароль")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Выход из аккаунта произведён успешно.")
    |> UserAuth.log_out_user()
  end
end
