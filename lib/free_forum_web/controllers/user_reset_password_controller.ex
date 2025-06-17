defmodule FreeForumWeb.UserResetPasswordController do
  use FreeForumWeb, :controller

  alias FreeForum.Accounts

  plug :get_user_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    conn
    |> put_flash(
      :info,
      "Если ваш адрес электронной почты есть в нашей системе, то вы вскоре получите письмо с инструкцей для сброса пароля."
    )
    |> redirect(to: ~p"/")
  end

  def edit(conn, _params) do
    render(conn, :edit, changeset: Accounts.change_user_password(conn.assigns.user))
  end

  def update(conn, %{"user" => user_params}) do
    case Accounts.reset_user_password(conn.assigns.user, user_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Пароль успешно изменён.")
        |> redirect(to: ~p"/users/log_in")

      {:error, changeset} ->
        render(conn, :edit, changeset: changeset)
    end
  end

  defp get_user_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if user = Accounts.get_user_by_reset_password_token(token) do
      conn |> assign(:user, user) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Ссылка на сброс пароля неверна или её срок дествия истёк.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
