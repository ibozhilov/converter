defmodule JSON.Parser.String do
	def parse(<<char::utf8, rest::binary>>) when char == 34 do
		case parse_string([], rest) do
			{:ok, result} -> result
			{:error, reason} -> {:error, reason}
		end
	end

	def parse(_) do
		{:error, "Unexpected data"}
	end

	defp parse_string(acc, <<>>) do
		{:error, "Unexpected end of buffer."}
	end


	defp parse_string(acc, <<char::utf8>>) when char == 34 do
		result = acc |> Enum.reverse() |> List.to_string()
		{:ok, result}
	end

	defp parse_string(acc, <<char::utf8, rest::binary>>) do
		parse_string([char | acc], rest)
	end

	defp parse_string(acc, json) do 
		{:error, "Could not decode char in string."}
	end
end