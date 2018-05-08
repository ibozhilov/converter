defmodule JSON.Parser.Array do
  def parse(<<"["::utf8, rest::binary>>) do
    rest
    |> String.trim()
    |> JSON.Parser.parse()
    |> format()
    |> process_array([])
  end

  def parse(_) do
    {:error, "Unexpected data"}
  end

  defp format(result) when not is_tuple(result) do
    {result, <<>>}
  end

  defp format({:error, {:has_rest, result, rest}}) do
    {result, String.trim(rest)}
  end

  defp format({:error, reason}) do
    {:error, reason}
  end

  defp process_array({item, <<"]"::utf8, rest::binary>>}, acc) do
    acc = [item | acc]
    result = Enum.reverse(acc)
    {:ok, result, rest}
  end

  defp process_array({item, <<","::utf8, rest::binary>>}, acc) do
    rest
    |> String.trim()
    |> JSON.Parser.parse()
    |> format()
    |> process_array([item | acc])
  end

  defp process_array({:error, reason}, _) do
    {:error, reason}
  end

  defp process_array({_, rest}, _) do
    {:error, "Expected ] got " <> rest}
  end
end
