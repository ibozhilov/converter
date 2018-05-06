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
    <<0xd0, 0::signed-integer>>
  end
  
  def pack(int) do
    header = int |> :math.log2() |> :math.ceil() 
    |> Kernel.+(1) |> Kernel./(8) |> :math.ceil() 
    |> :math.log2() |> :math.ceil() |> Kernel.trunc() |> Kernel.+(0xd0)
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
