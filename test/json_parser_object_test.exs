defmodule JsonParserObjectTest do
  use ExUnit.Case

  test "parse atom" do
    assert JSON.Parser.Object.parse(:a) == {:error, "Unexpected data"}
  end

  test "parse string" do
    assert JSON.Parser.Object.parse("\"some.string\"") == {:error, "Unexpected data"}
  end

  test "parse empty string" do
    assert JSON.Parser.Object.parse("") == {:error, "Unexpected data"}
  end

  test "parse int" do
    assert JSON.Parser.Object.parse("123") == {:error, "Unexpected data"}
  end

  test "parse non string key" do
    assert JSON.Parser.Object.parse("{1:1}") == {:error, "Unexpected data"}
  end

  test "parse unfinished Object" do
    assert Kernel.match?({:error, "Expected : got " <> _}, JSON.Parser.Object.parse("{\"a\""))
  end

  test "parse unfinished Object 2" do
    assert Kernel.match?({:error, _}, JSON.Parser.Object.parse("{\"a\":"))
  end

  test "parse unfinished Object 3" do
    assert Kernel.match?({:error, _}, JSON.Parser.Object.parse("{\"a\":}"))
  end

  test "parse unfinished Object 4" do
    assert Kernel.match?({:error, _}, JSON.Parser.Object.parse("{\"a\": 1"))
  end

  test "parse unfinished Object 5" do
    assert Kernel.match?({:error, _}, JSON.Parser.Object.parse("{\"a\": 1,"))
  end

  test "parse unfinished Object 6" do
    assert Kernel.match?({:error, _}, JSON.Parser.Object.parse("{\"a\": 1,}"))
  end

  test "parse Object" do
    assert JSON.Parser.Object.parse(
             "{\"key\" : 1 , \"key2\":{}, \"key3\":[\"value1\", 2 , {\"some, other,map\": null}]}"
           ) ==
             {:ok,
              %{
                "key" => 1,
                "key2" => %{},
                "key3" => ["value1", 2, %{"some, other,map" => nil}]
              }, ""}
  end
end
