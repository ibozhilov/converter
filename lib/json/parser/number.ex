defmodule JSON.Parser.Number do
	def parse(<<digit::utf8, _::binary>> = number) when digit in 48..57 do
		case parse_number([], number) do
			{:ok, {result, _}} -> result
			{:error, reason} -> {:error, reason}
		end
	end 

	def parse(<<"-"::utf8, rest::binary>>) do
		case parse_number(["-"], rest) do
			{:ok, {result, _}} -> result
			{:error, reason} -> {:error, reason}
		end
	end

	def parse(binary) do
		{:error, "Unable to parse as a number " <> binary}
	end

	defp parse_number(acc, <<digit::utf8, rest::binary>>) when digit in 48..57 do
		parse_number([digit | acc], rest)
	end

	defp parse_number(acc, <<46, rest::binary>>) do
		parse_float(["." | acc], rest)
	end

	defp parse_number(acc, <<exp::utf8, rest::binary>>) when exp in ["e", "E"] do
		parse_exponent([".", "0", "e" | acc], rest)
	end


	defp parse_number(acc, <<>>) do
		result = acc |> Enum.reverse() |> List.to_string() |> Integer.parse()
		{:ok, result}
	end

	defp parse_number(acc, binary) do
		{:error, "Unable to parse as a number " <> binary}
	end

	defp parse_float(acc, <<digit::utf8, rest::binary>>) when digit in 48..57 do
		parse_float([digit| acc], rest)
	end

	defp parse_float(acc, <<exp::utf8, rest::binary>>) when exp in ["e", "E"] do
		parse_exponent(["e" | acc], rest)
	end

	defp parse_float(acc, <<>>) do
		result = acc |> Enum.reverse() |> List.to_string() |> Float.parse()
		{:ok, result}
	end

	defp parse_float(acc, binary) do 
		{:error, "Unable to parse as a number " <> binary}
	end

	defp parse_exponent(acc, <<45, rest::binary>>) do
		parse_exponent_power(["-"| acc ], rest)
	end

	defp parse_exponent(acc, <<43, rest::binary>>) do
		parse_exponent_power(acc, rest)
	end

	defp parse_exponent(acc, <<digit::utf8, rest::binary>>) when digit in 48..57 do
		parse_exponent_power([digit | acc], rest)
	end

	defp parse_exponent(acc, binary) do
		{:error, "Could not parse as exponent" <> binary}
	end

	defp parse_exponent_power(acc, <<digit::utf8, rest::binary>>) when digit in 48..57 do
		parse_exponent_power([digit | acc], rest)
	end

	defp parse_exponent_power(acc, <<>>) do
		result = acc |> Enum.reverse() |> List.to_string() |> Float.parse()
		{:ok, result}
	end

	defp parse_exponent_power(acc, binary) do
		{:error, "Could not parse exponent power " <> binary}
	end

end