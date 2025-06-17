defmodule FreeForumWeb.TopicController do
  use FreeForumWeb, :controller

  alias FreeForum.UserContent
  alias FreeForum.UserContent.Topic

  def new(conn, _params) do
    changeset = UserContent.change_topic(%Topic{})
    render(conn, :new, page_title: "Начать новое обсуждение", changeset: changeset)
  end

  def create(conn, %{"topic" => topic_params}) do
    conn = FreeForumWeb.UserAuth.fetch_current_user(conn, %{})

    if user = conn.assigns[:current_user] do
      topic_params = topic_params
        |> Map.put("views", 0)
        |> Map.put("replies", 0)
        |> Map.put("author", user.id)
        |> Map.put("latest_activity", DateTime.utc_now())

      # HACK: Полное отсутствие валидации загружаемых файлов
      topic_params = if attachment = topic_params["attachment"] do
        {_, dir} = File.cwd()
        File.cp!(attachment.path, "#{dir}/priv/static/media/#{attachment.filename}")

        content = topic_params["content"]
        if String.starts_with?(attachment.content_type, "image") do
          Map.put(topic_params, "content", "#{content}\n<img src=\"#{~p"/media/#{attachment.filename}"}\" />")
        else
          Map.put(
            topic_params,
            "content",
            """
            #{content}
            <div class="flex mt-10 bg-gray-200 rounded-lg">
              <a
                class="px-6 py-4 w-full text-blue-600 hover:text-blue-800 visited:text-purple-600"
                href=#{~p"/media/#{attachment.filename}"}
              >
                <span class="hero-document"></span>
                <span class="inline-block underline px-1">#{attachment.filename}</span>
              </a>
            </div>
            """
          )
        end
      else
        topic_params
      end

      case UserContent.create_topic(topic_params) do
        {:ok, topic} ->
          conn
          |> put_flash(:info, "Обсуждение успешно создано.")
          |> redirect(to: ~p"/topics/#{topic}")

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, :new, changeset: changeset, topic: %{"title" => topic_params["title"], "content" => topic_params["content"]})
      end

    else
      conn
      |> put_flash(:error, "Для того чтобы создать обсуждение, необходимо войти в аккаунт")
      |> redirect(to: ~p"/users/log_in")
    end
  end

  # HACK: Ни в edit, ни в update нет проверок авторства, поэтому кто угодно может изменить любой пост
  def edit(conn, %{"id" => id}) do
    topic = UserContent.get_topic!(id) |> FreeForum.Repo.preload(:author)
    changeset = UserContent.change_topic(topic)
    render(conn, :edit, topic: topic, page_title: "Редактировать обсуждение", changeset: changeset)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = UserContent.get_topic!(id)

    case UserContent.update_topic(topic, topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Обсуждение успешно обновлено.")
        |> redirect(to: ~p"/topics/#{topic}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, topic: topic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = UserContent.get_topic!(id)
    {:ok, _topic} = UserContent.delete_topic(topic)

    conn
    |> put_flash(:info, "Обсуждение успешно удалено.")
    |> redirect(to: ~p"/topics")
  end
end
