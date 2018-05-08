defmodule JSON.Parser.Object do
  def parse(<<"{}"::utf8, rest::binary>>) do
    {:ok, %{}, rest}
  end

  def parse(<<"{"::utf8, rest::binary>>) do
    rest
    |> String.trim()
    |> JSON.Parser.String.parse()
    |> format()
    |> process_object_name_field(%{})
  end

  def parse(binary) do
    {:error, "Unexpected data"}
  end

  defp format(result) when not is_tuple(result) do
    {result, <<>>}
  end

  defp format({:error, {:has_rest, result, rest}}) do
    {result, String.trim(rest)}
  end

  defp format({:ok, result, rest}) do
    {result, String.trim(rest)}
  end

  defp format({:error, reason}) do
    {:error, reason}
  end

  defp process_object_name_field({:error, reason}, acc) do
    {:error, reason}
  end

  defp process_object_name_field({name, <<":"::utf8, rest::binary>>}, acc) do
    rest
    |> String.trim()
    |> JSON.Parser.parse()
    |> format()
    |> proccess_object_value_field(name, acc)
  end

  defp process_object_name_field({name, binary}, acc) do
    {:error, "Expected : got " <> binary}
  end

  defp proccess_object_value_field({:error, reason}, name, acc) do
    {:error, reason}
  end

  defp proccess_object_value_field({value, <<"}"::utf8, rest::binary>>}, name, acc) do
    acc = Map.put_new(acc, name, value)
    {:ok, acc, rest}
  end

  defp proccess_object_value_field({value, <<","::utf8, rest::binary>>}, name, acc) do
    acc = Map.put_new(acc, name, value)

    rest
    |> String.trim()
    |> JSON.Parser.String.parse()
    |> format()
    |> process_object_name_field(acc)
  end

  defp proccess_object_value_field({value, rest}, name, acc) do
    {:error, "Expected } got " <> rest}
  end
end
