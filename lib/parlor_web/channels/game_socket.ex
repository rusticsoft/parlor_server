defmodule ParlorWeb.GameSocket do
  @moduledoc false

  use Phoenix.Socket

  @version "0.1.0"

  channel "number", ParlorWeb.GameChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil

  @spec version() :: String.t()
  def version, do: @version
end
