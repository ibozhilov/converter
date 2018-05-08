defmodule JSON.Parser.Array do
  def parse(<<"["::utf8, rest::binary>>) do
    rest |> String.trim() |> JSON.Parser.parse() |> process_array([])
  end

  def parse(_) do
    {:error, "Unexpected data"}
  end

  defp process_array({:error, {:has_rest, item, <<"]"::utf8, rest::binary>>}}, acc) do
    acc = [item | acc]
    result = Enum.reverse(acc)
    {:ok, result, rest}
  end

  defp process_array({:error, {:has_rest, item, <<","::utf8, rest::binary>>}}, acc) do
    rest |> String.trim() |> JSON.Parser.parse() |> process_array([item | acc])
  end

  defp process_array({:error, {:has_rest, _, _}}) do
    {:error, "Unexpected end of buffer"}
  end

  defp process_array({:error, reason}, acc) do
    {:error, reason}
  end

  defp process_array(result, acc) when not is_tuple(result) do
    {:error, "Unexpected end of buffer"}
  end
end
