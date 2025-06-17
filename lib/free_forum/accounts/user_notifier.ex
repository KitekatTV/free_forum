defmodule FreeForum.Accounts.UserNotifier do
  import Swoosh.Email

  alias FreeForum.Mailer

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"FreeForum", "freeforum@hse.ru"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "FreeForum: Подтверждение электронной почты", """

    ==============================

    Здравствуйте #{user.username},

    Вы можете подтвердить свой аккаунт на FreeForum нажав на ссылку ниже:

    #{url}

    Если вы не создавали аккаунт, проигнорируйте это письмо.

    ==============================
    """)
  end

  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "FreeForum: Сброс пароля", """

    ==============================

    Здравствуйте #{user.email},

    Вы можете подтвердить сбросить свой пароль на FreeForum нажав на ссылку ниже:

    #{url}

    Если вы не запрашивали это изменение, проигнорируйте это письмо.

    ==============================
    """)
  end

  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "FreeForum: Инструкция по замене адреса эл. почты", """

    ==============================

    Здравствуйте #{user.email},

    Вы можете изменить адрес своей эл. почты на FreeForum нажав на ссылку ниже:

    #{url}

    Если вы не запрашивали это изменение, проигнорируйте это письмо.

    ==============================
    """)
  end
end
