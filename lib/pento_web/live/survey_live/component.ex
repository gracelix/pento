# functional (stateless) compoenent
defmodule PentoWeb.SurveyLive.Component do
  # Phoenix.Component behaviour gives us access to the ~H sigil for rendering HEEx templates
  use Phoenix.Component

  def hero(assigns) do
    ~H"""
      <h2>
        content: <%= @content %>
      </h2>
      <h3>
        slot: <%= render_slot(@inner_block) %>
      </h3>
    """
  end
end
