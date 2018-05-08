defmodule JsonParserArrayTest do
  use ExUnit.Case

  test "parse atom" do
    assert JSON.Parser.Array.parse(:a) == {:error, "Unexpected data"}
  end

  test "parse string" do
    assert JSON.Parser.Array.parse("\"some.string\"") == {:error, "Unexpected data"}
  end

  test "parse empty string" do
    assert JSON.Parser.Array.parse("") == {:error, "Unexpected data"}
  end

  test "parse int" do
    assert JSON.Parser.Array.parse("123") == {:error, "Unexpected data"}
  end

  test "parse unfinished array" do
    assert Kernel.match?({:error, _}, JSON.Parser.Array.parse("[1,2,"))
  end

  test "parse unfinished array 2" do
    assert JSON.Parser.Array.parse("[1,2") == {:error, "Unexpected end of buffer"}
  end

  test "parse array" do
    assert JSON.Parser.Array.parse("[1,   true,null, 2, \"t, e, s, t\", [false, 12E10]]") ==
             {:ok, [1, true, nil, 2, "t, e, s, t", [false, 1.2e11]], ""}
  end
end
