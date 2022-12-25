defmodule Nimble.Color.Format do
@moduledoc """
  Options:

  Which is fastest?

  1. Atom to be converted to color code at runtime
  2. At compile time, convert atoms to RGB keyword lists
      Then at run time, to escape codes
  3. At compile time, convert atoms to fully formatted strings
      (e.g. "$f03FFC8") to be parsed at run time

  Challenges:
    In the atom sequence, how to determine if foreground or background?

    [:gold_background, bright] # is this ok?
    [:bright, :background, :gold] # is this ok?
    [:bright, :gold, :reset, :background] # is this ok?

"""

  alias Nimble.Color.ANSII

  def puts(term, opts \\ [color: true]) do
    format(term, opts)
    |> IO.puts
  end

  def format(term, opts \\ [color: true]) do
    cond do
      is_list(term) -> _format(term, [], [], opts)
      is_binary(term) -> parse(term, opts)
    end
  end

  # Body Recursive Version
  def _format(term, rem, seq, opts)
  def _format([], [], [], _opts), do: []
  def _format([], [], seq, opts), do: [sequence(seq, opts)]

  def _format([term | rest], rem, seq, opts), do:
    _format(term, [rest | rem], seq, opts)

  def _format(term, [rest | rem], seq, opts) do
    cond do
      color?(term) ->
        _format(rest, rem, [term | seq], opts)
      match?([], seq) ->
        [term | _format(rest, rem, [], opts)]
      true ->
        [sequence(seq, opts), parse(term, opts) | _format(rest, rem, [], opts)]
    end
  end

  # Tail Recursive Version
  def __format(term, rem, seq, acc, opts)
  def __format([], [], [], acc, _opts), do: acc
  def __format([], [], seq, acc, opts), do: [sequence(seq, opts) | acc]

  def __format([term | rest], rem, seq, acc, opts), do:
    __format(term, [rest | rem], seq, acc, opts)

  def __format(term, [rest | rem], seq, acc, opts) do
    cond do
      color?(term) ->
        __format(rest, rem, [term | seq], acc, opts)
      match?([], seq) ->
        __format(rest, rem, [], [term | acc], opts)
      true ->
        __format(rest, rem, [], [term, sequence(seq, opts) | acc], opts)
    end
  end

  defp color?(term) do
    is_atom(term) or
    match?(%{r: _, g: _, b: _}, term) or
    match?({:background, %{r: _, g: _, b: _}}, term) or
    match?({:foreground, %{r: _, g: _, b: _}}, term)
  end

  defp parse(term, opts) when is_binary(term) do
    parser = get_parser(opts)
    case parser.(term) do
      {:ok, result, _, _, _, _} -> result
      {:error, _, _, _, _} -> term
    end
  end
  defp parse(term, _opts), do: term # do not parse non-binaries

  def get_parser(opts) do
    case Keyword.get(opts, :color) do
        true -> &Nimble.text_with_truecolor()/1
        256 -> &Nimble.text_with_color256()/1
        16 -> &Nimble.text_with_color16()/1
      false -> &Nimble.text_without_color()/1
    end
  end

#  def __get_parser(opts) do
#    {color, opts} = Keyword.pop(:color, opts)
#    case {ascii in opts, color} do
#      {false, nil}   -> utf8_truecolor()
#      {false, 256}   -> utf8_color256()
#      {false, 16}    -> utf8_color16()
#      {false, false} -> utf8_no_color()
#      {true, 16}     -> ascii_color16()
#      {true, 256}    -> ascii_color256()
#      {true, false}  -> ascii_no_color()
#      {true, nil}    -> ascii_truecolor()
#      _              -> ascii_no_color()
#    end
#  end

  defp sequence(seq, opts) do
    IO.puts "!"
    [h | t] = Enum.reverse(seq)
    case Keyword.get(opts, :color) do
      false -> [] # no color
      mode -> ["\e[", convert(h, mode) | _sequence(t, mode)]
    end
  end

  defp _sequence([], _mode), do: ["m"]
  defp _sequence([h | t], mode), do:
    [";", convert(h, mode) | _sequence(t, mode)]

  defp convert(term, mode) do
    case {term, mode} do
      {:reset, _} -> ?0
      {:default_color, _} -> "39"
      {:default_background, _} -> "49"
      {color, 16} -> to_16(color)
      {color, 256} -> to_256(color)
      {color, true} -> to_true(color)
    end
  end

  defp to_16({ground, rgb}), do: to_16(rgb, ground)
  defp to_16(%{r: r, g: g, b: b}, ground \\ :foreground) do
    ANSII.rgb_to_color256(r, g, b)
    |> ANSII.color256_to_code16(ground)
    |> Integer.to_string()
  end

#  defp to_16(color) when is_atom(color) do
#    color(color) |> to_16()
#  end

  defp to_256({ground, rgb}), do: to_256(rgb, ground)
  defp to_256(%{r: r, g: g, b: b}, ground \\ :foreground) do
    ground = ANSII.ground_code(ground)
    code256 = ANSII.rgb_to_color256(r, g, b)
    "#{ground};5;#{code256}"
  end

  defp to_true({ground, rgb}), do: to_true(rgb, ground)
  defp to_true(%{r: r, g: g, b: b}, ground \\ :foreground) do
    ground = ANSII.ground_code(ground)
    "#{ground};2;#{r};#{g};#{b}"
  end
end
