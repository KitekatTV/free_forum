defmodule FreeForumWeb.PageController do
  use FreeForumWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
