defmodule NimbleTest do
  use ExUnit.Case

  test "get" do
    {:ok, result, _, _, _, _} = Nimble.get("g  all big sword from yellow pack")
    IO.inspect result
  end

  test "look" do
    {:ok, result, _, _, _, _} = Nimble.look("look")
    IO.inspect result
  end
end
