defmodule FreeForumWeb.TopicHTML do
  use FreeForumWeb, :html
  import Flop.Phoenix

  embed_templates "topic_html/*"

  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def topic_form(assigns)

  attr :fields, :list, required: true
  attr :meta, Flop.Meta, required: true
  attr :id, :string, default: nil
  attr :on_change, :string, default: "update-filter"
  attr :on_reset, :string, default: "reset-filter"
  attr :placeholder, :string, default: nil
  attr :target, :string, default: nil

  def filter_form(%{meta: meta} = assigns) do
    assigns = assign(assigns, form: Phoenix.Component.to_form(meta), meta: nil)

    ~H"""
    <.form
      for={@form}
      id={@id}
      phx-target={@target}
      phx-change={@on_change}
      phx-submit={@on_change}
    >
      <.filter_fields :let={i} form={@form} fields={@fields}>
        <.input
          field={i.field}
          placeholder={@placeholder}
          type={i.type}
          phx-debounce={120}
          {i.rest}
        />
      </.filter_fields>
    </.form>
    """
  end
end
