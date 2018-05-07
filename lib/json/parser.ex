defmodule JSON.Parser do
	def parse("null") do
		nil
	end

	def parse(<<"true"::utf8>>) do
		true
	end

	def parse(<<"false"::utf8>>) do
		false
	end

	def parse(<<"{"::utf8, _::binary>> = object) do
		JSON.Parser.Object.parse(object)
	end

	def parse(<<"["::utf8, _::binary>> = array) do
		JSON.Parser.Array.parse(array)
	end

	def parse(<<digit::utf8, _::binary>> = number) when digit in 48..57 do
		JSON.Parser.Number.parse(number)
	end

	def parse(<<"-"::utf8, _::binary>> = number) do
		JSON.Parser.Number.parse(number)
	end

	def parse(<<quatation::utf8, _::binary>> = string) when quatation == 34 do 
		JSON.Parser.String.parse(string)
	end
end