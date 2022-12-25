defmodule Nimble do
  import NimbleParsec
  alias Nimble.Helpers
  alias Nimble.Color
  alias Nimble.Socials

  defparsec(:get, Helpers.get())
  defparsec(:look, Helpers.look())
  defparsec(:text_with_truecolor, Color.text_with_truecolor())
  defparsec(:text_with_color256, Color.text_with_color256())
  defparsec(:text_with_color16, Color.text_with_color16())
  defparsec(:text_without_color, Color.text_without_color())
  defparsec(:replacer, Socials.statement())
  defparsec(:rexpaint, Nimble.RexPaintXML.parser())
  defparsec(:data, Nimble.RexPaintXML.data())

  def replacement(text) do
    {:ok, result, _, _, _, _} = replacer(text)
    IO.inspect(result)
  end

  def puts16(text) do
    {:ok, result, _, _, _, _} = text_with_color16(text)
    IO.puts(result)
  end

  alias Nimble.Main.Config256
  alias Nimble.Main.ConfigTrueColor

  def process(file_path, config) do
    {:ok, parsed_data, _, _, _, _} = File.read!(file_path) |> rexpaint()

    converted_data =
      parsed_data
      |> convert_colors(config)
      |> minimize_color_codes(config)
      |> add_resets(config)

    file_path
    |> String.trim_trailing(".xml")
    |> then(fn file_path ->
      file_path <> ".txt"
    end)
    |> File.write!(converted_data)
  end

  def convert_colors(iolist, config) do
    case config do
      %Config256{} -> to_color256(iolist)
      %ConfigTrueColor{} -> iolist
    end
  end

  def to_color256(iolist) do
    iolist
    |> Enum.map(fn x ->
      case x do
        [ascii: char, fgd: fgd, bkg: bkg] ->
          [ascii: char, fgd: rgb_to_color256(fgd), bkg: rgb_to_color256(bkg)]

        _ ->
          x
      end
    end)
  end

  def minimize_color_codes(iolist, config = %Config256{}) do
    iolist
    |> Enum.reduce({[], {0, 0}}, fn x, {result, {last_fgd, last_bkg}} ->
      case x do
        [ascii: char, fgd: ^last_fgd, bkg: ^last_bkg] ->
          char = char
          {[char | result], {last_fgd, last_bkg}}

        [ascii: char, fgd: fgd, bkg: ^last_bkg] ->
          char = [EEx.eval_string(config.foreground, fgd: fgd), char]
          {[char | result], {fgd, last_bkg}}

        [ascii: char, fgd: ^last_fgd, bkg: bkg] ->
          char = [EEx.eval_string(config.background, bkg: bkg), char]
          {[char | result], {last_fgd, bkg}}

        [ascii: char, fgd: fgd, bkg: bkg] ->
          char = [
            EEx.eval_string(config.foreground, fgd: fgd),
            EEx.eval_string(config.background, bkg: bkg),
            char
          ]

          {[char | result], {fgd, bkg}}

        _ ->
          char = x
          {[char | result], {last_fgd, last_bkg}}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  def minimize_color_codes(iolist, config = %ConfigTrueColor{}) do
    iolist
    |> Enum.reduce({[], {0, 0}}, fn x, {result, {last_fgd, last_bkg}} ->
      case x do
        [ascii: char, fgd: ^last_fgd, bkg: ^last_bkg] ->
          char = char
          {[char | result], {last_fgd, last_bkg}}

        [ascii: char, fgd: fgd = [r1, g1, b1], bkg: ^last_bkg] ->
          char = [EEx.eval_string(config.foreground, r1: r1, g1: g1, b1: b1), char]
          {[char | result], {fgd, last_bkg}}

        [ascii: char, fgd: ^last_fgd, bkg: bkg = [r2, g2, b2]] ->
          char = [EEx.eval_string(config.background, r2: r2, g2: g2, b2: b2), char]
          {[char | result], {last_fgd, bkg}}

        [ascii: char, fgd: fgd = [r1, g1, b1], bkg: bkg = [r2, g2, b2]] ->
          char = [
            EEx.eval_string(config.foreground, r1: r1, g1: g1, b1: b1),
            EEx.eval_string(config.background, r2: r2, g2: g2, b2: b2),
            char
          ]

          {[char | result], {fgd, bkg}}

        _ ->
          char = x
          {[char | result], {last_fgd, last_bkg}}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  def add_resets(iolist, config) do
    [config.reset, iolist, config.reset]
  end

  def rgb_to_color256([r, g, b]) do
    Nimble.Color.ANSII.rgb_to_color256(r, g, b)
  end
end
