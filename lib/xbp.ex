defmodule Xbp do
  @moduledoc ~S"""
  Dumps binaries in a similar way to `xxd`.

  ## Examples

      Xbp.puts(<<1,2,3,255>> <> "Hello cruel world")
      #=> 0       01 02 03 FF 48 65 6C 6C 6F 20 63 72 75 65 6C 20   ....Hello cruel
      #=> 1       77 6F 72 6C 64                                    world
      :ok
  """

  import Enum,
    only: [chunk: 4, join: 2, map: 2, with_index: 1, zip: 2]

  @chunk_len 16
  @offset_len 8

  @space 32
  @tilde ?~
  @safe_to_print @space..@tilde

  @doc """
  Formats a binary dump and prints to stdio.
  """
  def puts(bx, f \\ &IO.puts/1),
  do: bx |> dump |> format |> f.()

  @doc ~S"""
  Dumps a binary into a list of indexed fragments.
  Every fragment consists of hexadecimal octets list and
  the corresponding printable ascii sequence.
  See chunk/1,2

      iex> Xbp.dump("abc")
      [{{["61", "62", "63"], 0}, {'abc', 0}}]
      iex> Xbp.dump("")
      []
      iex> Xbp.dump(<<255>>)
      [{{["FF"], 0}, {'.', 0}}]

  """
  def dump(bx) when is_binary bx do
    zip chunk(to_hexstr bx), chunk(to_printable bx)
  end

  @doc ~S"""
  Returns formatted IO list of binary dump fragments
  including their offsets.
  """
  def format([_|_]=frags) do
    map(frags, fn {{oct, idx}, {repr, idx}} ->
      index  = Integer.to_string(idx)
      octets = join(oct, " ")
      [ String.ljust(index,  @offset_len),
        String.ljust(octets, 2+@chunk_len*3),
        repr, "\n"]
    end)
  end
  def format([]), do: []

  @doc ~S"""
  Returns a list of chunks of max `n` elements each.
  Every chunk is wrapped in a tuple of {index, chunk}.

      iex> Xbp.chunk([1,2,3,4,5], 3)
      [{[1,2,3], 0}, {[4,5], 1}]
      iex> Xbp.chunk([1,2], 1)
      [{[1], 0}, {[2], 1}]
      iex> Xbp.chunk([])
      []

  """
  def chunk(l, n \\ @chunk_len),
  do: with_index chunk(l, n, n, [])

  @doc ~S"""
  Returns a list of shell-safe characters in a bitstring.
  Anything shady is being replaced with `.`

    iex> Xbp.to_printable("Hello" <> <<255, 0, 1>>)
    'Hello...'
  """
  def to_printable(bx) when is_binary bx do
    for <<b <- bx>>, do: byte_to_printable b
  end

  @doc ~S"""
  Converts arbitraty binary to a list of hex-encoded bytes

      iex> Xbp.to_hexstr(<<0,255,255,255,0,1>>)
      ["00", "FF", "FF", "FF", "00", "01"]
  """
  def to_hexstr(bx) when is_binary bx do
    for <<b <- bx>>, do: maybe_add_leading_0 (byte_to_hex b)
  end

  defp maybe_add_leading_0(b), do: String.rjust(b, 2, ?0)

  defp byte_to_hex(b) when b in 0..255, do: Integer.to_string(b, 16)

  defp byte_to_printable(b) when b in @safe_to_print, do: b
  defp byte_to_printable(_), do: ?.

end
