defmodule FreeForum.UserContent do
  @moduledoc """
  Модуль для взаиомдействия со всем контентом, создаваемым пользователем (Посты и комментарии).
  """

  import Ecto.Query, warn: false
  alias FreeForum.Repo

  alias FreeForum.UserContent.Topic

  def list_topics(params) do
    Flop.validate_and_run!(
      Topic,
      params,
      for: Topic
    )
  end

  def list_topics_non_vip(params) do
    Flop.validate_and_run!(
      from(t in Topic, where: t.vip != true),
      params,
      for: Topic
    )
  end

  def get_topic!(id), do: Repo.get!(Topic, id)

  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  def change_topic(%Topic{} = topic, attrs \\ %{}) do
    Topic.changeset(topic, attrs)
  end

  alias FreeForum.UserContent.Comment
  import Ecto

  def list_comments do
    Repo.all(Comment)
  end

  def list_comments_on_topic(topic, params) do
    query = from(t in Topic, where: t.id == ^topic, preload: :comments)
    {temp, meta} = Flop.validate_and_run!(query, params, for: Comment)
    comments = Enum.at(temp, 0).comments |> Repo.preload(:author)
    {comments, meta}
  end

  def get_comment!(id), do: Repo.get!(Comment, id)

  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
