defmodule JSON.Parser.Array do
	def parse(<<"["::utf8, rest::binary>>) do
		case parse_array([], "", rest) do
			{:ok, result} -> result
			{:error, reason} -> reason
		end
	end 

	defp parse_array(acc, item_acc, <<93>>) do
		acc = [item_acc | acc]
		result = acc |> Enum.reverse() |> Enum.map(fn(x) -> JSON.Parser.parse(x) end)
		{:ok, result}
	end

	defp parse_array(acc, item_acc, <<44, rest::binary>>) do
		parse_array([item_acc | acc], "", rest)
	end

	defp parse_array(acc, item_acc, <<char::utf8, rest::binary>>) do
		parse_array(acc, item_acc <> <<char>>, rest)
	end

	defp parse_array(acc, item_acc, <<>>) do
		{:error, "Unexpected end of buffer"}
	end
end