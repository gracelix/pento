defmodule PentoWeb.WrongLive do
  use Phoenix.LiveView, layout: {PentoWeb.LayoutView, "live.html"}

  alias PentoWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    {:ok,
     assign(socket,
       score: 0,
       message: "Make a guess:",
       answer: Enum.random([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) |> to_string(),
       is_correct: false,
       session_id: session["live_socket_id"]
     )}
  end

  def render(assigns) do
    ~H"""
      <h1>Your score: <%= @score %></h1>
      <h2>
        <%= @message %>
      </h2>
      <h2>
        <%= for n <- 1..10 do %>
          <a href="#" phx-click="guess" phx-value-number={n} ><%= n %></a>
        <% end %>
        <%!-- <pre>
          <%= @current_user.email %>
          <%= @session_id %>
        </pre> --%>
    </h2>
    <h2>
      <%= if @is_correct do%>
        <%= live_redirect "Play again!", to: Routes.live_path(@socket, PentoWeb.WrongLive) %>
      <% end %>
    </h2>
    """
  end

  def time(), do: DateTime.utc_now() |> to_string

  # handle_event/3: handle events sent by the client (ie. mouse click)
  #   1) message name
  #   2) map with metadata related to the event
  #   3) state for the live view (socket)

  def handle_event("guess", %{"number" => guess}, socket) do
    {msg, score, is_correct} = socket |> check_answer(guess)
    # IO.inspect(socket)
    {
      :noreply,
      socket
      |> assign(
        message: msg,
        score: score,
        is_correct: is_correct
      )
    }
  end

  defp check_answer(%{assigns: %{answer: answer, current_user: current_user}} = socket, guess) do
    case answer do
      ^guess -> {"Correct answer: #{guess}. Congratulations, #{current_user.username}!", socket.assigns.score + 1, true}
      ^answer -> {"Your answer: #{guess}. Wrong! Try again.", socket.assigns.score - 1, false}
    end
  end
end

# PRINT TO CONSOLE
# IO.inspect socket.assigns.answer, label: "answer"

# ALTERNATE METHOD -- PATTERN MATCHING answer WITH guess
# def handle_event("guess", %{"number" => guess}, %{assigns: %{answer: answer}} = socket) do
#   message = "Your guess: #{guess}. Wrong! Guess again."
#   score = socket.assigns.score - 1

#   {
#     :noreply,
#     assign(
#       socket,
#       message: message,
#       score: score
#     )
#   }
# end
# %{assigns: %{answer: answer, score: score}} = socket
