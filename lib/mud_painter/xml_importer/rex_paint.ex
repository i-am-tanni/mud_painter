defmodule MudPainter.XMLImporter.REXPaint do
  import NimbleParsec

  def parser() do
    ignore(header())
    |> concat(repeat(ignore_white_space()))
    |> concat(data())
  end

  defp header() do
    repeat(choice([string("<image>"), name(), height(), width(), white_space()]))
  end

  defp name() do
    string("<name>")
    |> repeat(choice([text(), string("</name>")]))
  end

  defp height() do
    string("<height>")
    |> repeat(choice([text(), string("</height>")]))
  end

  defp width() do
    string("<width>")
    |> repeat(choice([text(), string("</width>")]))
  end

  def data() do
    ignore_string("<data>")
    |> repeat(
      choice([
        row(),
        ignore_white_space(),
        ignore_string("</data>")
      ])
    )
  end

  defp row() do
    ignore_string("<row>")
    |> repeat(choice([blank_cell(), cell(), ignore_white_space(), row_end()]))
  end

  defp row_end() do
    ignore_string("</row>")
    |> replace(?\n)
  end

  defp cell() do
    ignore_string("<cell>")
    |> repeat(
      choice([
        ascii(),
        fgd(),
        bkg(),
        ignore_string("</cell>")
      ])
    )
    |> wrap()
  end

  defp blank_cell() do
    ignore(string("<cell><ascii>32</ascii><fgd>#000000</fgd><bkg>#000000</bkg></cell>"))
    |> replace(?\s)
  end

  defp ascii() do
    ignore_string("<ascii>")
    |> repeat(choice([integer(min: 1), ignore_string("</ascii>")]))
    |> unwrap_and_tag(:ascii)
  end

  def fgd() do
    ignore_string("<fgd>")
    |> repeat(choice([hex(), ignore_string("</fgd>")]))
    |> tag(:fgd)
  end

  def bkg() do
    ignore_string("<bkg>")
    |> repeat(choice([hex(), ignore_string("</bkg>")]))
    |> tag(:bkg)
  end

  def hex() do
    optional(ignore(utf8_char([?#])))
    |> concat(hex_code())
  end

  defp hex_code() do
    hex256()
    |> concat(hex256())
    |> concat(hex256())
    |> map({String, :to_integer, [16]})
  end

  defp hex256() do
    ascii_string([?0..?9, ?A..?F, ?a..?f], 2)
  end

  defp text(), do: utf8_string([not: ?<], min: 1)

  defp ignore_string(string) do
    ignore(string(string))
  end

  defp ignore_white_space() do
    ignore(white_space())
  end

  defp white_space() do
    utf8_char([?\s, ?\r, ?\n, ?\t, ?\d])
  end
end
