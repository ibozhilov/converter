defmodule Msgpack.Unpack do
  def unpack(<<>>) do
    {:error, "No data provided"}
  end

  def unpack(binary) do
    case unpack_msgpack(binary) do
      {:ok, result, <<>>} -> result
      {:ok, result, rest} -> {:error, {:has_rest, result, rest}}
      {:error, reason} -> {:error, reason}
    end
  end

  # Atoms
  defp unpack_msgpack(<<0xC0, rest::binary>>) do
    {:ok, nil, rest}
  end

  defp unpack_msgpack(<<0xC3, rest::binary>>) do
    {:ok, true, rest}
  end

  defp unpack_msgpack(<<0xC2, rest::binary>>) do
    {:ok, false, rest}
  end

  # Float
  defp unpack_msgpack(<<0xCB, num::float-64, rest::binary>>) do
    {:ok, num, rest}
  end

  # Integer
  defp unpack_msgpack(<<0xD0, num::signed-integer-8, rest::binary>>) do
    {:ok, num, rest}
  end

  defp unpack_msgpack(<<0xD1, num::signed-integer-16, rest::binary>>) do
    {:ok, num, rest}
  end

  defp unpack_msgpack(<<0xD2, num::signed-integer-32, rest::binary>>) do
    {:ok, num, rest}
  end

  defp unpack_msgpack(<<0xD3, num::signed-integer-64, rest::binary>>) do
    {:ok, num, rest}
  end

  # String
  defp unpack_msgpack(<<0b101::3, n::unsigned-integer-5, str::binary-size(n), rest::binary>>) do
    {:ok, str, rest}
  end

  defp unpack_msgpack(<<0xD9, n::unsigned-integer-8, str::binary-size(n), rest::binary>>) do
    {:ok, str, rest}
  end

  defp unpack_msgpack(<<0xDA, n::unsigned-integer-16, str::binary-size(n), rest::binary>>) do
    {:ok, str, rest}
  end

  defp unpack_msgpack(<<0xDB, n::unsigned-integer-32, str::binary-size(n), rest::binary>>) do
    {:ok, str, rest}
  end

  # List
  defp unpack_msgpack(<<9::4, n::unsigned-integer-4, rest::binary>>) do
    unpack_list(rest, n)
  end

  defp unpack_msgpack(<<0xDC, n::unsigned-integer-16, rest::binary>>) do
    unpack_list(rest, n)
  end

  defp unpack_msgpack(<<0xDD, n::unsigned-integer-32, rest::binary>>) do
    unpack_list(rest, n)
  end

  # Map
  defp unpack_msgpack(<<8::4, n::unsigned-integer-4, rest::binary>>) do
    unpack_map(rest, n)
  end

  defp unpack_msgpack(<<0xDE, n::unsigned-integer-16, rest::binary>>) do
    unpack_map(rest, n)
  end

  defp unpack_msgpack(<<0xDF, n::unsigned-integer-32, rest::binary>>) do
    unpack_map(rest, n)
  end

  defp unpack_msgpack(binary) do
    {:error, "Unknow data " <> binary}
  end

  # Process List
  defp unpack_list(binary, size) do
    process_list(binary, size, [])
  end

  defp process_list(binary, 0, acc) do
    acc = Enum.reverse(acc)
    {:ok, acc, binary}
  end

  defp process_list(binary, n, acc) do
    with {:ok, result, rest} <- unpack_msgpack(binary),
         do: process_list(rest, n - 1, [result | acc])
  end

  # Process Map
  defp unpack_map(binary, size) do
    with {:ok, result, rest} <- unpack_list(binary, size * 2),
         do:
           {:ok,
            result
            |> Enum.chunk(2)
            |> Enum.map(fn [a, b] -> {a, b} end)
            |> Map.new(), rest}
  end
end
