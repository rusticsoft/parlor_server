defmodule Parlor.GameChannelTest do
  use ParlorWeb.ChannelCase, async: false

  import Parlor.Factory

  alias Parlor.Games
  alias ParlorWeb.GameSocket

  setup do
    %{socket: socket(GameSocket)}
  end

  test "phx_join replies with expected join message", %{socket: socket} do
    game_pid = start_supervised!(Games.Number)
    %Games.Number.State{room_code: room_code} = :sys.get_state(game_pid)

    handle = handle()

    assert {:ok, %{message: message}, _socket} =
             subscribe_and_join(socket, "number", %{room_code: room_code, handle: handle})

    assert message ==
             "Welcome to Number! Joined room #{room_code} as #{handle}. Socket version #{GameSocket.version()}."
  end
end
