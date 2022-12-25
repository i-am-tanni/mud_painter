defmodule Nimble.Main.Config256 do
  defstruct [:foreground, :background, :reset, symbol: "{c}", base: 10]
end

defmodule Nimble.Main.ConfigTrueColor do
  defstruct [:foreground, :background, :reset, r: "{r}", g: "{g}", b: "{b}", base: 10]
end

defmodule Nimble.Main.Test do
  def config256() do
    %Nimble.Main.Config256{
      symbol: "{c}",
      foreground: "\\e[38;5;{c}m",
      background: "\\e[48;5;{c}m",
      reset: "\\e[0m",
      base: 10
    }
  end

  def config_true_color() do
    %Nimble.Main.ConfigTrueColor{
      foreground: "\\e[38;2;{r};{g};{b}m",
      background: "\\e[48;2;{r};{g};{b}m",
      reset: "\\e[0m",
      base: 10
    }
  end
end

defmodule Nimble.Main do
  alias Nimble.Main.ConfigTrueColor
  alias Nimble.Main.Config256

  def main() do
    config = load_config()
    config = to_eex(config)
    Nimble.process("data/test.xml", config)
  end

  defp load_config() do
    Nimble.Main.Test.config256()
  end

  defp to_eex(config = %ConfigTrueColor{}) do
    foreground =
      config.foreground
      |> String.replace(config.r, "<%= Integer.to_string(r1, #{config.base}) %>")
      |> String.replace(config.g, "<%= Integer.to_string(g1, #{config.base}) %>")
      |> String.replace(config.b, "<%= Integer.to_string(b1, #{config.base}) %>")

    background =
      config.background
      |> String.replace(config.r, "<%= Integer.to_string(r2, #{config.base}) %>")
      |> String.replace(config.g, "<%= Integer.to_string(g2, #{config.base}) %>")
      |> String.replace(config.b, "<%= Integer.to_string(b2, #{config.base}) %>")

    %{config | foreground: foreground, background: background}
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
end
