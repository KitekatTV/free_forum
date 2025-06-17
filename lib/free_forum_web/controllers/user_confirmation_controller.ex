defmodule FreeForumWeb.UserConfirmationController do
  use FreeForumWeb, :controller

  alias FreeForum.Accounts

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    conn
    |> put_flash(
      :info,
      "Если ваш адрес электронной почты уже в нашей системе, но еще не был подтверждён, " <>
        "ты вы вскоре получите электронной письмо для подтверждения."
    )
    |> redirect(to: ~p"/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, :edit, token: token)
  end

  def update(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Подтверждение успешно!")
        |> redirect(to: ~p"/")

      :error ->
        case conn.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: ~p"/")

          %{} ->
            conn
            |> put_flash(:error, "Ссылка для подтверждения неверна или её срок действия истёк.")
            |> redirect(to: ~p"/")
        end
    end
  end
end
