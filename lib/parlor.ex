defmodule Parlor do
  @moduledoc """
  Function to support starting and running games.
  """

  alias Parlor.Registry

  @doc """
  Generates a unique four-letter room code.
  """
  @spec generate_room_code() :: String.t()
  def generate_room_code do
    existing_room_codes = Parlor.Registry.list_room_codes()
    room_code = for _ <- 1..4, into: "", do: <<Enum.random(?a..?z)>>

    if Enum.member?(existing_room_codes, room_code) do
      generate_room_code()
    else
      room_code
    end
  end

  @doc """
  Join the game identified by `room_code` as `handle`.
  """
  @spec join_game(String.t(), String.t()) :: :ok | {:error, :handle_taken}
  def join_game(room_code, handle) do
    room_code
    |> Registry.get!()
    |> GenServer.call({:register_player, handle})
  end

  @doc """
  Return the state of the game identified by the given `pid` or `room_code`.
  """
  @spec inspect_game(pid | String.t()) :: struct
  def inspect_game(pid) when is_pid(pid) do
    :sys.get_state(pid)
  end

  def inspect_game(room_code) do
    room_code
    |> Registry.get!()
    |> inspect_game()
  end

  @doc """
  Return the state of all games.
  """
  @spec inspect_games() :: [struct]
  def inspect_games, do: Enum.map(Registry.list_room_codes(), &inspect_game/1)
end
