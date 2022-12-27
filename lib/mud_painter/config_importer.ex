defmodule MudPainter.ConfigImporter do
  alias MudPainter.Config16
  alias MudPainter.Config256
  alias MudPainter.ConfigTrueColor

  def run(path) do
    case String.ends_with?(path, ".json") do
      true ->
        File.read!(path)
        |> Jason.decode!()
        |> to_struct()
        |> to_eex()

      false ->
        raise "Error - config file must be in .json format"
    end
  end

  defp to_struct(json = %{"color_mode" => "truecolor"}) do
    %ConfigTrueColor{
      r: Map.fetch!(json, "r"),
      g: Map.fetch!(json, "g"),
      b: Map.fetch!(json, "b"),
      foreground: Map.fetch!(json, "foreground"),
      background: Map.fetch!(json, "background"),
      reset: Map.fetch!(json, "reset"),
      base: Map.fetch!(json, "base")
    }
  end

  defp to_struct(json = %{"color_mode" => color_mode}) when color_mode in ["256", 256] do
    %Config256{
      symbol: Map.fetch!(json, "symbol"),
      foreground: Map.fetch!(json, "foreground"),
      background: Map.fetch!(json, "background"),
      reset: Map.fetch!(json, "reset"),
      base: Map.fetch!(json, "base")
    }
  end

  defp to_struct(json = %{"color_mode" => color_mode}) when color_mode in ["16", 16] do
    foreground = %{} = json["foreground"]
    background = %{} = json["background"]

    %Config16{
      symbol: Map.fetch!(json, "symbol"),
      pattern: Map.fetch!(json, "pattern"),
      reset: Map.fetch!(json, "reset"),
      foreground: %{
        0 => Map.fetch!(foreground, "0"),
        1 => Map.fetch!(foreground, "1"),
        2 => Map.fetch!(foreground, "2"),
        3 => Map.fetch!(foreground, "3"),
        4 => Map.fetch!(foreground, "4"),
        5 => Map.fetch!(foreground, "5"),
        6 => Map.fetch!(foreground, "6"),
        7 => Map.fetch!(foreground, "7"),
        8 => Map.fetch!(foreground, "8"),
        9 => Map.fetch!(foreground, "9"),
        10 => Map.fetch!(foreground, "10"),
        11 => Map.fetch!(foreground, "11"),
        12 => Map.fetch!(foreground, "12"),
        13 => Map.fetch!(foreground, "13"),
        14 => Map.fetch!(foreground, "14"),
        15 => Map.fetch!(foreground, "15")
      },
      background: %{
        0 => Map.fetch!(background, "0"),
        1 => Map.fetch!(background, "1"),
        2 => Map.fetch!(background, "2"),
        3 => Map.fetch!(background, "3"),
        4 => Map.fetch!(background, "4"),
        5 => Map.fetch!(background, "5"),
        6 => Map.fetch!(background, "6"),
        7 => Map.fetch!(background, "7"),
        8 => Map.fetch!(background, "8"),
        9 => Map.fetch!(background, "9"),
        10 => Map.fetch!(background, "10"),
        11 => Map.fetch!(background, "11"),
        12 => Map.fetch!(background, "12"),
        13 => Map.fetch!(background, "13"),
        14 => Map.fetch!(background, "14"),
        15 => Map.fetch!(background, "15")
      }
    }
  end

  defp to_struct(_) do
    """
    Error: Json file lacking expected field "color mode"
      with value in one of the following: "truecolor", "256", "16"
    """
    |> raise()
  end

  defp to_eex(config = %Config16{}) do
    pattern =
      config.pattern
      |> String.replace(config.symbol, "<%= code %>")

    %{config | pattern: pattern}
  end

  defp to_eex(config = %Config256{}) do
    foreground =
      config.foreground
      |> String.replace(config.symbol, "<%= Integer.to_string(fgd, #{config.base}) %>")

    background =
      config.background
      |> String.replace(config.symbol, "<%= Integer.to_string(bkg, #{config.base}) %>")

    %{config | foreground: foreground, background: background}
  end

  defp to_eex(config = %ConfigTrueColor{}) do
    foreground =
      config.foreground
      |> String.replace(
        config.r,
        "<%= MudPainter.Converter.to_string_and_pad(r1, #{config.base}, \"#{config.r}\") %>"
      )
      |> String.replace(
        config.g,
        "<%= MudPainter.Converter.to_string_and_pad(g1, #{config.base}, \"#{config.g}\") %>"
      )
      |> String.replace(
        config.b,
        "<%= MudPainter.Converter.to_string_and_pad(b1, #{config.base}, \"#{config.b}\") %>"
      )

    background =
      config.background
      |> String.replace(
        config.r,
        "<%= MudPainter.Converter.to_string_and_pad(r2, #{config.base}, \"#{config.r}\") %>"
      )
      |> String.replace(
        config.g,
        "<%= MudPainter.Converter.to_string_and_pad(g2, #{config.base}, \"#{config.g}\") %>"
      )
      |> String.replace(
        config.b,
        "<%= MudPainter.Converter.to_string_and_pad(b2, #{config.base}, \"#{config.b}\") %>"
      )

    %{config | foreground: foreground, background: background}
  end
end
