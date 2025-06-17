defmodule FreeForumWeb.Live.Topic do
  use FreeForumWeb, :live_view

  alias FreeForum.Accounts
  alias FreeForum.UserContent

  @impl true
  def render(assigns) do
    ~H"""
    <.back navigate={~p"/topics"}>Назад</.back>

    <.header>
      <div class="w-full flex justify-between">
        <a>
          <%= if @topic.vip do %>
            <.icon class="p-1" name="hero-star"/>
          <% end %>
          <span class="font-semibold">{@topic.title}</span>
          <span class="font-normal text-gray-400"> от </span>
          <span class="font-normal">{Accounts.get_user!(@topic.author_id).username}</span>
        </a>
        <div class="overflow-visible">
          <nobr>
            <.icon name="hero-eye" />
            <span class="inline-block align-top pl-1 pt-0.5">{@topic.views}</span>
          </nobr>
        </div>
      </div>
      <:actions>
        <%= if @current_user && @current_user.id == @topic.author_id do %>
          <.link href={~p"/topics/#{@topic}/edit"}>
            <.button>Редактировать</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <hr class="solid my-4"/>

    <div class="flex" style="flex-direction: column">
      <!-- HACK: Просто отображать HTML без какой-либо валидации - огромная дыра для XSS -->
      {raw(@topic.content)}
    </div>

    <hr class="solid my-4"/>

    <!-- TODO: Move to components -->
    <%= if is_nil(@reply_to) do %>
      <div phx-click-away="close-reply">
        <.simple_form :let={f} for={@changeset} action={~p"/topics/#{@topic}/comment"} class="bg-transparent flex flex-row w-full content-end items-end gap-x-2">
          <.input required field={f[:content]} type="text" label="Оставить комментарий" />
          <:actions>
            <div class="flex w-full items-center justify-between">
              <.button>Опубликовать</.button>
            </div>
          </:actions>
        </.simple_form>
      </div>
    <% end %>

    <Flop.Phoenix.table
      opts={[
        table_attrs: [class: "text-sm text-left"],
        thead_th_attrs: [class: "px-2 pt-3 pb-1 text-start text-xs font-medium"],
        tbody_attrs: [class: "divide-y divide-gray-200"],
        tbody_td_attrs: [class: "px-4 py-4 whitespace-nowrap"],
      ]}
      items={@comments}
      meta={@meta}
      path={~p"/topics/#{@topic}"}
    >
      <:col :let={comment} label={"#{length(@comments)} комментария"} field={:content}>
        <div class="flex ml-2 content-start" style="flex-direction: column">
          <%= if comment.replies_to do %>
            <a>
              <span class="font-semibold">{comment.author.username}</span>
              <span class="text-gray-400"> ответил на </span>
              <span>{UserContent.get_comment!(comment.replies_to).content}</span>
            </a>
          <% else %>
            <a class="font-semibold">{comment.author.username}</a>
          <% end %>

          <a class="text-wrap">{comment.content}</a>
          <button class="text-start text-blue-600 text-xs" phx-click="reply" phx-value-replyto={comment.id}>Ответить</button>

          <%= if @reply_to == comment.id |> to_string() do %>
            <div phx-click-away="close-reply">
              <.simple_form :let={f} for={@changeset} action={~p"/topics/#{@topic}/comment"} class="bg-transparent flex flex-row w-full content-end items-end gap-x-2">
                <.input required field={f[:content]} type="text" label="Оставить комментарий" />
                <div class="hidden">
                  <.input field={f[:replies_to]} type="number" value={comment.id} />
                </div>
                <:actions>
                  <div class="flex w-full items-center justify-between">
                    <.button>Опубликовать</.button>
                  </div>
                </:actions>
              </.simple_form>
            </div>
          <% end %>
        </div>
      </:col>
    </Flop.Phoenix.table>

    <Flop.Phoenix.pagination meta={@meta} path={~p"/topics/#{@topic}"} />
    """
  end

  @impl true
  def mount(params, session, socket) do
    token = Map.get(session, "user_token")

    current_user = case session do
      %{"user_token" => token} -> Accounts.get_user_by_session_token(token)
      _ -> nil
    end

    if topic = params["topic"] do
      topic = UserContent.get_topic!(topic) |> FreeForum.Repo.preload(:author)
      UserContent.update_topic(topic, %{"views" => topic.views + 1})
    end

    {:ok, assign(
      socket,
      reply_to: nil,
      current_user: current_user,
      comments: [],
      meta: %{},
      changeset: UserContent.change_comment(
        %UserContent.Comment{},
        %{"topic" => 0, "author" => 0}
      )
    )}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _, socket) do
    topic = UserContent.get_topic!(Map.get(params, "topic"))
    {comments, meta} = UserContent.list_comments_on_topic(topic.id, params)
    {:noreply, assign(socket, topic: topic, comments: comments, meta: meta)}
  end

  @impl true
  def handle_event("reply", params, socket) do
    {:noreply, assign(
      socket,
      reply_to: Map.get(params, "replyto"),
      changeset: UserContent.change_comment(
        %UserContent.Comment{},
        %{"topic" => 0, "author" => 0}
      )
    )}
  end

  @impl true
  def handle_event("close-reply", params, socket) do
    {:noreply, assign(
      socket,
      reply_to: nil,
      changeset: UserContent.change_comment(
        %UserContent.Comment{},
        %{"topic" => 0, "author" => 0}
      )
    )}
  end
end
