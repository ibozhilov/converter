defprotocol Msgpack.Paker do
  def pack(item)
end

defimpl Msgpack.Paker, for: Atom do
  def pack(nil) do
    <<0xC0>>
  end

  def pack(true) do
    <<0xC3>>
  end

  def pack(false) do
    <<0xC2>>
  end

  def pack(atom) do
    atom |> Atom.to_string() |> Msgpack.Paker.pack()
  end
end

defimpl Msgpack.Paker, for: Float do
  def pack(num) do
    <<0xCB, num::float>>
  end
end

defimpl Msgpack.Paker, for: Integer do
  def pack(0) do
    <<0xD0, 0::signed-integer>>
  end

  def pack(int) do
    header =
      int
      |> :math.log2()
      |> :math.ceil()
      |> Kernel.+(1)
      |> Kernel./(8)
      |> :math.ceil()
      |> :math.log2()
      |> :math.ceil()
      |> Kernel.trunc()
      |> Kernel.+(0xD0)

    <<header, int::signed-integer>>
  end
end

defimpl Msgpack.Paker, for: BitString do
  def pack(str) when byte_size(str) < 32 do
    <<0b101::3, byte_size(str)::5, str::binary>>
  end

  def pack(str) when byte_size(str) < 256 do
    <<0xD9, byte_size(str)::8, str::binary>>
  end

  def pack(str) when byte_size(str) < 65536 do
    <<0xDA, byte_size(str)::16, str::binary>>
  end

  def pack(str) when byte_size(str) < 4_294_967_296 do
    <<0xDB, byte_size(str)::32, str::binary>>
  end
end

defimpl Msgpack.Paker, for: List do
  def pack(array) when length(array) < 16 do
    header = <<9::4, length(array)::4>>
    process_array(array, header)
  end

  def pack(array) when length(array) < 65536 do
    header = <<0xDC, length(array)::16>>
    process_array(array, header)
  end

  def pack(array) when length(array) < 4_294_967_296 do
    header = <<0xDD, length(array)::32>>
    process_array(array, header)
  end

  defp process_array([], acc) do
    acc
  end

  defp process_array([h | t], acc) do
    process_array(t, <<acc::binary, Msgpack.Paker.pack(h)::binary>>)
  end
end

defimpl Msgpack.Paker, for: Map do
  def pack(m) when map_size(m) < 16 do
    header = <<8::4, map_size(m)::4>>
    m_as_list = Map.to_list(m)
    process_map(m_as_list, header)
  end

  def pack(m) when map_size(m) < 65536 do
    header = <<0xDE, map_size(m)::16>>
    m_as_list = Map.to_list(m)
    process_map(m_as_list, header)
  end

  def pack(m) when map_size(m) < 4_294_967_296 do
    header = <<0xDF, map_size(m)::32>>
    m_as_list = Map.to_list(m)
    process_map(m_as_list, header)
  end

  defp process_map([], acc) do
    acc
  end

  defp process_map([h | t], acc) do
    {k, v} = h
    process_map(t, <<acc::binary, Msgpack.Paker.pack(k)::binary, Msgpack.Paker.pack(v)::binary>>)
  end
end
