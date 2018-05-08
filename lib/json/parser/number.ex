defmodule JSON.Parser.Number do
  def parse(<<digit::utf8, _::binary>> = number) when digit in 48..57 do
    case parse_number([], number) do
      {:ok, {result, _}, rest} -> {:ok, result, rest}
      {:error, reason} -> {:error, reason}
    end
  end

  def parse(<<"-"::utf8, rest::binary>>) do
    case parse_number(["-"], rest) do
      {:ok, {result, _}, rest} -> {:ok, result, rest}
      {:error, reason} -> {:error, reason}
    end
  end

  def parse(_) do
    {:error, "Unexpected data"}
  end

  # Parse int digits
  defp parse_number(acc, <<digit::utf8, rest::binary>>) when digit in 48..57 do
    parse_number([digit | acc], rest)
  end

  # If there is a dot parse as float
  defp parse_number(acc, <<46, rest::binary>>) do
    parse_float(["." | acc], rest)
  end

  # If there is an exponent parse as exponent
  defp parse_number(acc, <<exp::utf8, rest::binary>>) when exp in [101, 69] do
    parse_exponent(["e", "0", "." | acc], rest)
  end

  # Process int result
  defp parse_number(acc, <<rest::binary>>) do
    result = acc |> Enum.reverse() |> List.to_string() |> Integer.parse()
    {:ok, result, rest}
  end

  # Parse float digits
  defp parse_float(acc, <<digit::utf8, rest::binary>>) when digit in 48..57 do
    parse_float([digit | acc], rest)
  end

  # Parse float exponent
  defp parse_float(acc, <<exp::utf8, rest::binary>>) when exp in [101, 69] do
    parse_exponent(["e" | acc], rest)
  end

  # Process float result
  defp parse_float(acc, <<rest::binary>>) do
    result = acc |> Enum.reverse() |> List.to_string() |> Float.parse()
    {:ok, result, rest}
  end

  # Parse minus sign of the exponent
  defp parse_exponent(acc, <<45, rest::binary>>) do
    parse_exponent_power(["-" | acc], rest)
  end

  # Parse plus sign of the exponent
  defp parse_exponent(acc, <<43, rest::binary>>) do
    parse_exponent_power(acc, rest)
  end

  # Parse exponent digits
  defp parse_exponent(acc, <<digit::utf8, rest::binary>>) when digit in 48..57 do
    parse_exponent_power([digit | acc], rest)
  end

  # If there is no number after the exponent sign throw error
  defp parse_exponent(_, _) do
    {:error, "Could not parse exponent"}
  end

  # Parse exponent power digits
  defp parse_exponent_power(acc, <<digit::utf8, rest::binary>>) when digit in 48..57 do
    parse_exponent_power([digit | acc], rest)
  end

  # Process exponent result
  defp parse_exponent_power(acc, <<rest::binary>>) do
    result = acc |> Enum.reverse() |> List.to_string() |> Float.parse()
    {:ok, result, rest}
  end
end
