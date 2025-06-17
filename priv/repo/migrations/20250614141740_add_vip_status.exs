defmodule FreeForum.Repo.Migrations.AddVipStatus do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :vip, :boolean, default: false
    end

    alter table("topics") do
      add :vip, :boolean, default: false
    end
  end
end
