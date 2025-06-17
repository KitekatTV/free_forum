defmodule FreeForumWeb.CommentController do
  use FreeForumWeb, :controller

  alias FreeForum.UserContent
  alias FreeForum.UserContent.Comment

  def create(conn, %{"comment" => comment_params, "topic" => topic} = params) do
    conn = FreeForumWeb.UserAuth.fetch_current_user(conn, %{})

    if user = conn.assigns[:current_user] do
      comment_params = comment_params
      |> Map.put("topic", topic)
      |> Map.put("author", user.id)
      |> Map.put("likes", 0)

      case UserContent.create_comment(comment_params) do
        {:ok, comment} ->
          topic = comment.topic |> FreeForum.Repo.preload(:author)
          UserContent.update_topic(topic, %{replies: topic.replies + 1})

          conn
          |> put_flash(:info, "Комментарий оставлен.")
          |> redirect(to: ~p"/topics/#{topic}")

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> put_flash(:error, "Что-то пошло не так...")
          |> redirect(to: ~p"/topics/#{topic}")
      end
    else
      conn
      |> put_flash(:error, "Для того чтобы оставить комментарий, необходимо войти в аккаунт")
      |> redirect(to: ~p"/users/log_in")
    end
  end

  # TODO: Comments editing?
  def edit(conn, %{"id" => id}) do
    comment = UserContent.get_comment!(id)
    changeset = UserContent.change_comment(comment)
    # render(conn, :edit, topic: topic, changeset: changeset)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = UserContent.get_comment!(id)

    case UserContent.update_comment(comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Комментарий обновлён.")
        |> redirect(to: ~p"/topics/#{comment.topic.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, comment: comment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = UserContent.get_comment!(id)
    {:ok, _comment} = UserContent.delete_comment(comment)

    conn
    |> put_flash(:info, "Комментарий удалён.")
    |> redirect(to: ~p"/topics")
  end
end
