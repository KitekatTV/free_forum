defmodule FreeForum.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :content, :text
      add :tags, {:array, :string}
      add :views, :integer
      add :replies, :integer
      add :latest_activity, :naive_datetime
      add :author_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:topics, [:author_id])
  end
end
