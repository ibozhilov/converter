defmodule JsonParserTest do
  use ExUnit.Case

  test "parse nil" do
    assert JSON.Parser.parse("null") == nil
  end

  test "parse true" do
    assert JSON.Parser.parse("true") == true
  end

  test "parse false" do
    assert JSON.Parser.parse("false") == false
  end

  test "parse string" do
    assert JSON.Parser.parse(<<?", "test string"::binary, ?">>) == "test string"
  end

  test "parse string with rest" do
    assert JSON.Parser.parse(<<?", "test string"::binary, ?", 123::integer>>) ==
             {:error, {:has_rest, "test string", <<123::integer>>}}
  end
end
