defmodule JsonPackerTest do
  use ExUnit.Case

  test "pack nil" do
    assert JSON.Packer.pack(nil) == "null"
  end

  test "pack true" do
    assert JSON.Packer.pack(true) == "true"
  end

  test "pack false" do
    assert JSON.Packer.pack(false) == "false"
  end

  test "pack atom" do
    assert JSON.Packer.pack(:atom) == "\"atom\""
  end

  test "pack number" do
    assert JSON.Packer.pack(-1.23e-15) == "-1.23e-15"
  end

  test "pack array" do
    a = [1, true, "test", "t, e, s, t", ["new array", %{}]]
    assert JSON.Packer.pack(a) == "[1, true, \"test\", \"t, e, s, t\", [\"new array\", {}]]"
  end

  test "pack map with non string key" do
  	assert JSON.Packer.pack(%{1=>2}) == {:error, "Only string names are allowed in JSON Object. Got 1"}
  end
  
  test "pack map" do
    m = %{
      "atom" => :atom,
      "nil" => nil,
      "bool" => true,
      "map" => %{"array" => [1, 2, %{}]},
      "empty_array" => []
    }
    assert JSON.Packer.pack(m) == "{\"atom\": \"atom\", \"bool\": true, \"empty_array\": [], \"map\": {\"array\": [1, 2, {}]}, \"nil\": null}"
  end
end
