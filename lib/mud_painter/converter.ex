defmodule MudPainter.Converter do
  alias MudPainter.XMLImporter
  alias MudPainter.ConfigTrueColor
  alias MudPainter.Config256
  alias MudPainter.Config16
  alias MudPainter.Converter.Downsample

  def run(file_path, config) do
    parsed_data = XMLImporter.process(file_path)

    converted_data =
      parsed_data
      |> convert_colors(config)
      |> minimize_color_codes(config)
      |> add_resets(config)

    file_path = file_path |> String.trim_trailing(".xml")
    file_path = file_path <> ".txt"

    File.write!(file_path, converted_data)
    IO.puts("Success! \"\e[33m#{file_path}\e[0m\" created.")
  end

  defp convert_colors(iolist, config) do
    case config do
      %Config256{} ->
        to_color256(iolist)

      %Config16{} ->
        iolist
        |> to_color16()

      %ConfigTrueColor{} ->
        iolist
    end
  end

  defp to_color256(iolist) do
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

  defp to_color16(iolist) do
    iolist
    |> Enum.map(fn x ->
      case x do
        [ascii: char, fgd: fgd, bkg: bkg] ->
          [ascii: char, fgd: rgb_to_color16(fgd), bkg: rgb_to_color16(bkg)]

        _ ->
          x
      end
    end)
  end

  defp minimize_color_codes(iolist, config = %Config256{}) do
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

  defp minimize_color_codes(iolist, config = %ConfigTrueColor{}) do
    iolist
    |> Enum.reduce({[], {0, 0}}, fn x, {result, {last_fgd, last_bkg}} ->
      case x do
        [ascii: char, fgd: ^last_fgd, bkg: ^last_bkg] ->
          char = char
          {[char | result], {last_fgd, last_bkg}}

        [ascii: char, fgd: fgd = [r1, g1, b1], bkg: ^last_bkg] ->
          char = [EEx.eval_string(config.foreground, r1: r1, g1: g1, b1: b1), char]
          IO.puts("r: #{r1}, g: #{g1}, b: #{b1}")
          IO.inspect(config.foreground)
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

  defp minimize_color_codes(iolist, config = %Config16{}) do
    iolist
    |> Enum.reduce({[], {0, 0}}, fn x, {result, {last_fgd, last_bkg}} ->
      case x do
        [ascii: char, fgd: ^last_fgd, bkg: ^last_bkg] ->
          char = char
          {[char | result], {last_fgd, last_bkg}}

        [ascii: char, fgd: fgd, bkg: ^last_bkg] ->
          char = [EEx.eval_string(config.pattern, code: Map.fetch!(config.foreground, fgd)), char]
          {[char | result], {fgd, last_bkg}}

        [ascii: char, fgd: ^last_fgd, bkg: bkg] ->
          char = [EEx.eval_string(config.pattern, code: Map.fetch!(config.foreground, bkg)), char]
          {[char | result], {last_fgd, bkg}}

        [ascii: char, fgd: fgd, bkg: bkg] ->
          char = [
            EEx.eval_string(config.pattern, code: Map.fetch!(config.foreground, fgd)),
            EEx.eval_string(config.pattern, code: Map.fetch!(config.foreground, bkg)),
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

  def to_string_and_pad(integer, base, symbol) do
    padding = padding_amount(symbol)

    integer
    |> Integer.to_string(base)
    |> String.pad_leading(padding, "0")
  end

  # Returns the largest count of repeated characters in the symbol
  # Does NOT consider consecutive / nonconsecutive repetitions
  defp padding_amount(symbol) do
    charlist = String.to_charlist(symbol)

    charlist
    |> Enum.map(fn char ->
      Enum.count(charlist, &(&1 == char))
    end)
    |> Enum.max()
  end

  defp add_resets(iolist, %{reset: reset}) do
    [reset, iolist, reset]
  end

  defp rgb_to_color256([r, g, b]) do
    Downsample.rgb_to_color256(r, g, b)
  end

  defp rgb_to_color16([r, g, b]) do
    Downsample.rgb_to_color256(r, g, b)
    |> Downsample.color256_to_color16()
  end
end
