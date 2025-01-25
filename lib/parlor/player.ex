defmodule Parlor.Player do
  @moduledoc """
  A game participant with a handle and optional data.
  """

  @enforce_keys :handle
  defstruct [:handle, data: %{winner?: false}]
end
