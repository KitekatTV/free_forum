defmodule FreeForumWeb.Live.Topics do
  use FreeForumWeb, :live_view
  import FreeForumWeb.TopicHTML

  alias FreeForum.Accounts
  alias FreeForum.UserContent

  def format_activity(latest_activity) do
    minutes = NaiveDateTime.diff(DateTime.utc_now(), latest_activity, :minute)
    hours = div(minutes, 60)
    days = div(hours, 24)

    cond do
      minutes < 10 ->
        "Только что"
      days <= 1 ->
        "Сегодня"
      days < 5 ->
        "#{days} дня назад"
      days < 7 ->
        "#{days} дней назад"
      days < 14 ->
        "Неделю назад"
      true ->
        "Давно"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex gap-4" style="flex-direction: column">
      <div class="w-full flex flex-row-reverse">
        <div class="basis-1/4 content-center">
          <.link href={~p"/topics/new"}>
            <.button class="w-full">Создать обсуждение</.button>
          </.link>
        </div>

        <div class="pr-4 basis-3/4 content-center">
          <.filter_form
            fields={[
              title: [
                op: :like
              ],
            ]}
            meta={@meta}
            placeholder="Начните печатать для поиска по обсуждениям"
            id="topic-filter-form"
          />
        </div>
      </div>

      <div class="w-full overflow-auto max-h-100">
        <Flop.Phoenix.table
          opts={[
            table_attrs: [class: "w-full text-sm text-left text-gray-500"],
            thead_attrs: [class: "bg-gray-50"],
            thead_th_attrs: [class: "px-6 py-3 text-start text-xs text-gray-500 font-medium"],
            th_wrapper_attrs: [class: "flex items-center"],
            tbody_attrs: [class: "divide-y divide-gray-200"],
            tbody_tr_attrs: [class: "bg-white hover:bg-amber-200"],
            tbody_td_attrs: [class: "px-6 py-4 whitespace-nowrap text-sm"],
          ]}
          items={@streams.topics}
          meta={@meta}
          path={~p"/topics"}
          row_click={fn {_, topic} -> JS.navigate(~p"/topics/#{topic}") end}
        >
          <:col :let={{_, topic}} label="Тема" field={:title}>
            <a class="w-full">
              <span>{topic.title}</span>
              <%= if topic.vip do %>
                <.icon name="hero-star-mini"/>
              <% end %>
            </a>
          </:col>

          <:col :let={{_, topic}} label="Ответов" field={:replies}>
            <a class="w-full text-center">
              {topic.replies}
            </a>
          </:col>

          <:col :let={{_, topic}} label="Просмотров" field={:views}>
            <a class="w-full text-center">
              {topic.views}
            </a>
          </:col>

          <:col :let={{_, topic}} label="Последняя активность" field={:latest_activity}>
            <a class="w-full text-center">
              {format_activity(topic.latest_activity)}
            </a>
          </:col>
        </Flop.Phoenix.table>
        <!-- TODO: Pagination? (Probably not needed) -->
        <!-- <Flop.Phoenix.pagination meta={@meta} path={~p"/topics"} /> -->
        <!-- <div :if={@meta.total_pages > 1}> -->
          <!-- <div>Showing {@meta.current_offset + 1}-{min(@meta.current_offset + @meta.page_size, @meta.total_count)}</div> -->
        <!-- </div> -->
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, map, socket) do
    current_user = case map do
      %{"user_token" => token} -> Accounts.get_user_by_session_token(token)
      _ -> nil
    end

    {:ok, assign(socket, page_title: "Недавнее", current_user: current_user, topics: [], meta: %{})}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _, socket) do
    {topics, meta} = case socket do
      %{assigns: %{current_user: %{vip: true}}} -> UserContent.list_topics(params)
      _ -> UserContent.list_topics_non_vip(params)
    end

    {:noreply, socket |> assign(meta: meta) |> stream(:topics, topics, reset: true)}
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/topics?#{params}")}
  end

  @impl true
  def handle_event("reset-filter", _, %{assigns: assigns} = socket) do
    flop = assigns.meta.flop
      |> Flop.set_page(1)
      |> Flop.reset_filters()

    path = Flop.Phoenix.build_path(~p"/topics", flop, backend: assigns.meta.backend)
    {:noreply, push_patch(socket, to: path)}
  end
end
