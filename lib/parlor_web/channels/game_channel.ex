defmodule ParlorWeb.GameChannel do
  use Gettext, backend: Parlor.Gettext
  use ParlorWeb, :channel

  alias Parlor.Games.Number
  alias ParlorWeb.GameSocket

  @impl true
  def join("number", %{"room_code" => room_code, "handle" => handle}, socket) do
    socket =
      socket
      |> assign(:room_code, room_code)
      |> assign(:handle, handle)

    Parlor.join_game(room_code, handle)

    {:ok, %{message: join_message(room_code, handle)}, socket}
  end

  @impl true
  def handle_in("guess", %{"guess" => guess}, socket) do
    %{room_code: room_code, handle: handle} = socket.assigns
    Number.register_guess(room_code, handle, guess)
    {:noreply, socket}
  end

  @spec join_message(String.t(), String.t()) :: String.t()
  defp join_message(room_code, handle) do
    gettext(
      "Welcome to Number! Joined room %{room_code} as %{handle}. Socket version %{version}.",
      room_code: room_code,
      handle: handle,
      version: GameSocket.version()
    )
  end
end
