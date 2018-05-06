defmodule JSON.Parser do
	def parse("null") do
		nil
	end

	def parse("true") do
		true
	end

	def parse("false") do
		false
	end

	def parse("{" <> _ = object) do
		JSON.Parser.Object.parse(object)
	end

	def parse("[" <> _ = array) do
		JSON.Parser.Array.parse(array)
	end

	def parse(<<digit::utf8, _::binary>> = number) when digit in 48..57 do
		JSON.Parser.Number.parse(number)
	end

	def parse("-" <> _ = number) do
		JSON.Parser.Number.parse(number)
	end

	def parse(<<quatation::utf8, _::binary>> = string) when quatation == 34 do 
		JSON.Parser.String.parse(string)
	end
end