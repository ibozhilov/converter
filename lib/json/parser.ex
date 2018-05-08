defmodule JSON.Parser do
  def parse(<<>>) do
    {:error, "No data provided"}
  end

  def parse(<<json::binary>>) do
    case parse_json(json) do
      {:ok, result, <<>>} -> result
      {:ok, result, rest} -> {:error, {:has_rest, result, rest}}
      {:error, reason} -> {:error, reason}
    end
  end

  def parse(data) do
    {:error, "Non binary data provided" <> data}
  end

  defp parse_json(<<"null"::utf8, rest::binary>>) do
    {:ok, nil, rest}
  end

  defp parse_json(<<"true"::utf8, rest::binary>>) do
    {:ok, true, rest}
  end

  defp parse_json(<<"false"::utf8, rest::binary>>) do
    {:ok, false, rest}
  end

  defp parse_json(<<"{"::utf8, _::binary>> = object) do
    JSON.Parser.Object.parse(object)
  end

  defp parse_json(<<"["::utf8, _::binary>> = array) do
    JSON.Parser.Array.parse(array)
  end

  defp parse_json(<<digit::utf8, _::binary>> = number) when digit in 48..57 do
    JSON.Parser.Number.parse(number)
  end

  defp parse_json(<<"-"::utf8, _::binary>> = number) do
    JSON.Parser.Number.parse(number)
  end

  defp parse_json(<<quatation::utf8, _::binary>> = string) when quatation == 34 do
    JSON.Parser.String.parse(string)
  end

  defp parse_json(binary) do
    {:error, "Do not know how to process " <> binary}
  end
end
