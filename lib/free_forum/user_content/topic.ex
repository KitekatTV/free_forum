defmodule FreeForum.UserContent.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  use FreeForumWeb, :live_view

  @derive {
    Flop.Schema,
    filterable: [:title, :comments_content],
    sortable: [:latest_activity, :views, :replies],
    adapter_opts: [
      join_fields: [
        comments_content: [
          binding: :comments,
          field: :content,
        ]
      ]
    ]
  }

  schema "topics" do
    field :title, :string
    field :replies, :integer
    field :content, :string
    field :tags, {:array, :string}
    field :views, :integer
    field :vip, :boolean, default: false
    field :latest_activity, :naive_datetime

    belongs_to :author, FreeForum.Accounts.User
    has_many :comments, FreeForum.UserContent.Comment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title, :content, :tags, :views, :replies, :latest_activity, :vip])
    |> cast_author_id(attrs)
    |> validate_required([:title, :content, :views, :replies, :latest_activity, :vip, :author])
  end

  defp cast_author_id(changeset, attrs) do
    if author_id = attrs["author"] do
      if author_id != 0 do
        put_assoc(changeset, :author, FreeForum.Accounts.get_user!(author_id))
      else
        changeset
      end
    else
      changeset
    end
  end
end
