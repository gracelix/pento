defmodule PentoWeb.UserAuthLive do
  import Phoenix.LiveView
  alias Pento.Accounts

  def on_mount(_, _params, %{"user_token" => user_token}, socket) do
    # user = Accounts.get_user_by_session_token(user_token)
    IO.inspect(socket.private, label: "assign user with socket.private:")
    socket =
      socket
      |> assign_new(:current_user, fn ->
        # db query only executed on second, connected mount
        Accounts.get_user_by_session_token(user_token)
      end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/login")}
    end
  end
end
