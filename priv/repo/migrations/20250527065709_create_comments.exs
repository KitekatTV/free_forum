defmodule FreeForum.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text
      add :likes, :integer
      add :topic_id, references(:topics, on_delete: :nothing)
      add :author_id, references(:users, on_delete: :nothing)
      add :replies_to, references(:comments, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:topic_id])
    create index(:comments, [:author_id])
    create index(:comments, [:replies_to])
  end
end
