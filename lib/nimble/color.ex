defmodule Nimble.Color do
  import NimbleParsec

  @moduledoc """
  Contains parsers that consume text with the color codes specified below
  and produce the same text with ansii escape sequences. The escape sequence is dictated by the parser selected.
  * text_without_color - no colors
  * text_with_color16() - 16 color
  * text_with_color256() - 256 color output
  * text_with_truecolor() - truecolor RGB output

  #Color formats embedded in the text that can be converted to colorful output
    $xFF     - 256 color code (base 16)
    $xFFFFFF - true color hex codes (RGB)

    $ start of color code sequence
    x = f or b (standing for foreground or background)

    Examples:

    "The quick $hfA52A2A/brown$/r fox jumps over the"

    $hfFF0000 - red foreground text, RGB(255, 0, 0)
    $xf09 - xterm 256 color - red foreground text, RGB(255, 0, 0)

    $/r = reset foreground and background
    $/f = reset foreground
    $/b = reset background
  """

  def text_with_color16(), do: text_with_color(:to_color16)
  def text_with_color256(), do: text_with_color(:to_color256)
  def text_with_truecolor(), do: text_with_color(:to_truecolor)

  def text_without_color() do
    repeat(choice([text(), ignore(color_statement()), utf8_char([?$])]))
  end

  def text_with_color(mode) do
    repeat(choice([text(), color_statement(mode), utf8_char([?$])]))
  end

  defp color_statement(mode \\ :to_color16) do
    choice([color_formats(mode), reset_statement()])
  end

  defp color_formats(mode) do
    choice([true_color(), color256()])
    |> map({__MODULE__.ANSII, mode, []})
  end

  defp reset_statement() do
    choice([reset(), default_background(), default_foreground()])
  end

  defp true_color() do
    choice([foreground_rgb(), background_rgb()])
    |> unwrap_and_tag(:truecolor)
  end

  def color256() do
    choice([foreground256(), background256()])
    |> unwrap_and_tag(:color256)
  end

  # def test({ground, code}) do
  #  "\e[#{ground_code(ground)};5;#{code}m"
  # end

  def ground_code(ground) do
    case ground do
      :foreground -> 38
      :background -> 48
    end
  end

  defp foreground_rgb() do
    ignore(string("$hf"))
    |> concat(hex_code())
    |> optional(ignore(string("/")))
    |> tag(:foreground)
  end

  defp background_rgb() do
    ignore(string("$hb"))
    |> concat(hex_code())
    |> optional(ignore(string("/")))
    |> tag(:background)
  end

  defp foreground256() do
    ignore(string("$xf"))
    |> concat(hex256())
    |> map({String, :to_integer, [16]})
    |> optional(ignore(string("/")))
    |> unwrap_and_tag(:foreground)
  end

  defp background256() do
    ignore(string("$xb"))
    |> concat(hex256())
    |> map({String, :to_integer, [16]})
    |> optional(ignore(string("/")))
    |> unwrap_and_tag(:background)
  end

  defp reset() do
    ignore(string("$\r"))
    |> replace("\e[0m")
  end

  defp default_background() do
    ignore(string("$\b"))
    |> replace("\e[49m")
  end

  defp default_foreground() do
    ignore(string("$\f"))
    |> replace("\e[39m")
  end

  defp text(), do: utf8_string([not: ?$], min: 1)

  defp hex_code() do
    hex256()
    |> concat(hex256())
    |> concat(hex256())
    |> map({String, :to_integer, [16]})
  end

  defp hex256() do
    ascii_string([?0..?9, ?A..?F, ?a..?f], 2)
  end
end
