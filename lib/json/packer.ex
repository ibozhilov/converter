defprotocol JSON.Packer do
  def pack(item)
end

defimpl JSON.Packer, for: Atom do
  def pack(nil) do
    "null"
  end

  def pack(false) do
    "false"
  end

  def pack(true) do
    "true"
  end

  def pack(atom) do
    atom |> Atom.to_string() |> JSON.Packer.pack()
  end
end

defimpl JSON.Packer, for: Integer do
  def pack(num) do
    Integer.to_string(num)
  end
end

defimpl JSON.Packer, for: Float do
  def pack(num) do
    Float.to_string(num)
  end
end

defimpl JSON.Packer, for: BitString do
  def pack(string) do
    "\"" <> string <> "\""
  end
end

defimpl JSON.Packer, for: List do
  def pack(list) when list == [] do
    "[]"
  end

  def pack(list) do
    "[" <> pack_list(list) <> "]"
  end

  defp pack_list([h | []]) do
    JSON.Packer.pack(h)
  end

  defp pack_list([h | t]) do
    JSON.Packer.pack(h) <> ", " <> pack_list(t)
  end
end

defimpl JSON.Packer, for: Map do
  def pack(map) when map == %{} do
    "{}"
  end

  def pack(map) do
    map_as_list = Map.to_list(map)

    case pack_map(map_as_list) do
      {:ok, json} -> "{" <> json <> "}"
      {:error, reason} -> {:error, reason}
    end

    #  with {:ok, json} <- pack_map(map_as_list) do
    #   "{" <> json <> "}"
    # end
  end

  defp pack_map([h | []]) do
    pack_member(h)
  end

  defp pack_map([h | t]) do
    with {:ok, json_head} <- pack_member(h),
         {:ok, json_tail} <- pack_map(t),
         do: {:ok, json_head <> ", " <> json_tail}
  end

  defp pack_member({k, v})
       when is_atom(k) and not is_boolean(k) and not is_nil(k)
       when is_bitstring(k) do
    {:ok, JSON.Packer.pack(k) <> ": " <> JSON.Packer.pack(v)}
  end

  defp pack_member({k, _}) do
    {:error, "Only string names are allowed in JSON Object. Got " <> Kernel.inspect(k)}
  end
end
