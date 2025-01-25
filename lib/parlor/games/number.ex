defmodule Parlor.Games.Number do
  @moduledoc """
  A number-guessing game.
  """

  use GenServer

  require Logger

  alias Parlor.Player

  @type phase :: :lobby | :guessing | :results

  defmodule State do
    @type t :: %__MODULE__{
            room_code: String.t(),
            number: pos_integer(),
            phase: Parlor.Games.Number.phase(),
            players: [Parlor.Player]
          }
    @enforce_keys ~w(room_code number)a
    defstruct [:room_code, :number, phase: :lobby, players: []]
  end

  @doc """
  Starts a new `Parlor.Games.Number` process.

  ## Options

    * `state` - Starting `Parlor.Games.Number.State`.
  """
  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts \\ []) do
    number = Enum.random(1..100)
    room_code = Parlor.generate_room_code()
    Logger.info("Room code: #{room_code}")
    state = Keyword.get(opts, :state, %State{room_code: room_code, number: number})
    GenServer.start_link(__MODULE__, state, name: name(room_code))
  end

  ## Client API

  @doc """
  Transitions the game to the given `phase`.
  """
  @spec transition(String.t(), phase) :: :ok
  def transition(room_code, phase) do
    GenServer.call(name(room_code), {:transition, phase})
  end

  @doc """
  Register guess on behalf of player with `handle`.
  """
  @spec register_guess(String.t(), String.t(), pos_integer) :: :ok
  def register_guess(room_code, handle, guess) do
    GenServer.call(name(room_code), {:register_guess, handle, guess})
  end

  ## Server Callbacks

  @impl true
  def init(state) do
    Parlor.Registry.put!(state.room_code, self())
    {:ok, state}
  end

  @impl true
  def handle_call({:transition, :guessing}, _from, %State{phase: :lobby} = state) do
    {:reply, :ok, %{state | phase: :guessing}}
  end

  def handle_call({:register_player, handle}, _from, %State{phase: :lobby} = state) do
    {reply, new_state} =
      case fetch_player(state.players, handle) do
        {:ok, _} ->
          {{:error, :handle_taken}, state}

        :error ->
          players = [%Player{handle: handle}] ++ state.players
          {:ok, %{state | players: players}}
      end

    {:reply, reply, new_state}
  end

  def handle_call({:register_guess, handle, guess}, _from, %State{phase: :guessing} = state) do
    players = update_player(state.players, handle, %{guess: guess, winner?: false})
    new_state = %{state | players: players}

    new_state =
      if Enum.any?(players, &is_nil(Map.get(&1.data, :guess))) do
        new_state
      else
        new_state
        |> determine_winner()
        |> Map.replace!(:phase, :results)
      end

    {:reply, :ok, new_state}
  end

  def handle_call(msg, from, state) do
    Logger.debug("Unhandled message: #{inspect({msg, from, state})}")
    {:reply, :ok, state}
  end

  ## Helpers

  @spec name(String.t()) :: {:global, __MODULE__, String.t()}
  defp name(room_code), do: {:global, {__MODULE__, room_code}}

  @spec fetch_player([Player.t()], String.t()) :: {:ok, Player.t()} | :error
  defp fetch_player(players, handle) do
    case Enum.find(players, &(&1.handle == handle)) do
      nil -> :error
      player -> {:ok, player}
    end
  end

  @spec update_player([Player.t()], String.t(), map) :: [Player.t()]
  defp update_player(players, handle, data) do
    Enum.map(players, fn
      %Player{handle: ^handle} = player -> %{player | data: data}
      player -> player
    end)
  end

  @spec determine_winner(State.t()) :: State.t()
  defp determine_winner(%State{players: players, number: number} = state) do
    {winner, _} =
      Enum.reduce(players, {nil, nil}, fn player, {_, best_diff} = acc ->
        guess_diff = number - player.data.guess
        if guess_diff >= 0 and guess_diff < best_diff, do: {player, guess_diff}, else: acc
      end)

    players =
      if is_nil(winner) do
        players
      else
        Logger.info("#{winner.handle} wins!")
        update_player(players, winner.handle, %{winner.data | winner?: true})
      end

    %{state | players: players}
  end
end
