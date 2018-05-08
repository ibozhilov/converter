defmodule JsonParserNumberTest do
  use ExUnit.Case

  test "parse atom" do
    assert JSON.Parser.Number.parse(:a) == {:error, "Unexpected data"}
  end

  test "parse string" do
    assert JSON.Parser.Number.parse("\"some.string\"") == {:error, "Unexpected data"}
  end

  test "parse empty string" do
    assert JSON.Parser.Number.parse("") == {:error, "Unexpected data"}
  end

  test "parse int" do
    assert JSON.Parser.Number.parse("123") == {:ok, 123, ""}
  end

  test "parse signed int" do
    assert JSON.Parser.Number.parse("-123") == {:ok, -123, ""}
  end

  test "parse double dot" do
    assert JSON.Parser.Number.parse("-123.123.123") == {:ok, -123.123, ".123"}
  end

  test "parse signed float" do
    assert JSON.Parser.Number.parse("-123.314") == {:ok, -123.314, ""}
  end

  test "parse int with exponent" do
    assert JSON.Parser.Number.parse("-123e10") == {:ok, -1.23e12, ""}
  end

  test "parse float with plus exponent" do
    assert JSON.Parser.Number.parse("-123.45e+10") == {:ok, -1.2345e12, ""}
  end

  test "parse float with minus exponent" do
    assert JSON.Parser.Number.parse("-123.45e-10") == {:ok, -1.2345e-8, ""}
  end
end
