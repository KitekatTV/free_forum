# Шаблон, автосгенерированный при создании проекта Phoenix (mix phx.new)

defmodule FreeForumWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use FreeForumWeb, :controller` and
  `use FreeForumWeb, :live_view`.
  """
  use FreeForumWeb, :html

  embed_templates "layouts/*"
end
