defmodule Parlor.Registry do
  @moduledoc """
  A global registry of all running game processes. Game PIDs are stored in
  the registry under their room code.
  """

  use GenServer

  ## Client API

  @doc """
  Starts the registry process.
  """
  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Puts a new entry in the registry.
  """
  @spec put!(String.t(), pid) :: :ok
  def put!(room_code, pid) do
    GenServer.call(__MODULE__, {:put!, room_code, pid})
  end

  @doc """
  Gets an entry from the registry.
  """
  @spec get!(String.t()) :: pid
  def get!(room_code) do
    GenServer.call(__MODULE__, {:get!, room_code})
  end

  @doc """
  Returns the list of room codes.
  """
  @spec list_room_codes() :: [String.t()]
  def list_room_codes do
    GenServer.call(__MODULE__, :list_room_codes)
  end

  ## Server Callbacks

  @impl true
  def init(_init_arg) do
    table = :ets.new(__MODULE__, [:named_table, read_concurrency: true])
    {:ok, table}
  end

  @impl true
  def handle_call({:put!, room_code, pid}, _from, table) do
    true = :ets.insert_new(table, {room_code, pid})
    {:reply, :ok, table}
  end

  def handle_call({:get!, room_code}, _from, table) do
    [{_, pid}] = :ets.lookup(table, room_code)
    {:reply, pid, table}
  end

  def handle_call(:list_room_codes, _from, table) do
    room_codes =
      table
      |> :ets.tab2list()
      |> Enum.map(&elem(&1, 0))

    {:reply, room_codes, table}
  end
end
