defmodule Nimble.Helpers do
  import NimbleParsec

  def get() do
    choice([word("g"), word("ge"), word("get")])
    |> verb(:get)
    |> optional(all())
    |> concat(dobj())
    |> optional(iobj("from"))
  end

  def look() do
    choice([word("l"), word("lo"), word("look")])
    |> verb(:look)
    |> optional(string("at"))
    |> choice([dobj(), eos() |> replace(:room) |> unwrap_and_tag(:dobj)])
  end

  defp all() do
    ignore(string("all"))
    |> ignore_white_space()
    |> replace(true)
    |> unwrap_and_tag(:all)
  end

  defp dobj() do
    times(lookahead_not(preposition()) |> concat(word()), min: 1)
    |> tag(:dobj)
  end

  defp iobj(str) do
    ignore(string(str))
    |> ignore_white_space()
    |> times(word(), min: 1)
    |> tag(:iobj)
  end

  def verb(combinator, replacement) do
    combinator
    |> replace(replacement)
    |> ignore_white_space()
    |> unwrap_and_tag(:verb)
  end

  def word() do
    ascii_string([?a..?z], min: 2)
    |> ignore_white_space()
  end

  def word(str) do
    string(str)
    |> lookahead(choice([white_space(), eos()]))
  end

  defp ignore_white_space(combinator) do
    combinator
    |> choice([ignore(times(white_space(), min: 1)), eos()])
  end

  defp white_space(combinator \\ empty()) do
    combinator
    |> ascii_char([?\s, ?\r, ?\n, ?\t, ?\d])
  end

  defp preposition() do
    choice([string("from"), string("to")])
  end

end