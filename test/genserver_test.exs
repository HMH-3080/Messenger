defmodule GenserverTest do
  use ExUnit.Case
  doctest Genserver

  test "greets the world" do
    assert Genserver.hello() == :world
  end
end
