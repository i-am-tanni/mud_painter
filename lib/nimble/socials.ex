defmodule Nimble.Socials do
  import NimbleParsec

  def statement() do
    command_statement() |> optional(character_statement()) |> eos()
  end

  def command_statement() do
    word() |> unwrap_and_tag(:command)
  end

  def character_statement() do
    word() |> unwrap_and_tag(:character)
  end

  def word() do
    utf8_string([?a..?z], min: 2)
    |> ignore_white_space()
  end

  defp ignore_white_space(combinator) do
    combinator
    |> choice([ignore(times(white_space(), min: 1)), eos()])
  end

  defp white_space(combinator \\ empty()) do
    combinator
    |> ascii_char([?\s, ?\r, ?\n, ?\t, ?\d])
  end
end
