defmodule JsonParserStringTest do
  use ExUnit.Case

  test "parse 1" do
    assert JSON.Parser.String.parse(1) == {:error, "Unexpected data"}
  end

  test "parse atom" do
    assert JSON.Parser.String.parse(:a) == {:error, "Unexpected data"}
  end

  test "parse unfinished string" do
    assert JSON.Parser.String.parse("\"abc") == {:error, "Unexpected end of buffer."}
  end

  test "parse empty string" do
    assert JSON.Parser.String.parse("") == {:error, "Unexpected data"}
  end

  test "parse string without rest" do
    assert JSON.Parser.String.parse("\"some.random.string13234\"") ==
             {:ok, "some.random.string13234", ""}
  end

  test "parse string with rest" do
    assert JSON.Parser.String.parse("\"some.random.string13234\"123") ==
             {:ok, "some.random.string13234", "123"}
  end
end
