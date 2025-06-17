defmodule FreeForum.UserContent.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [],
    sortable: []
  }

  schema "comments" do
    field :content, :string
    field :likes, :integer
    field :replies_to, :id

    belongs_to :topic, FreeForum.UserContent.Topic
    belongs_to :author, FreeForum.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :likes, :replies_to])
    |> cast_ids(attrs)
    |> validate_required([:content, :likes, :topic, :author])
  end

  defp cast_ids(changeset, attrs) do
    topic = attrs["topic"]
    author = attrs["author"]

    if topic != 0 and author != 0 do
      changeset
      |> put_assoc(:topic, FreeForum.UserContent.get_topic!(topic))
      |> put_assoc(:author, FreeForum.Accounts.get_user!(author))
    else
      changeset
    end
  end
end
