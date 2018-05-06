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