defmodule MudPainter.XMLImporter do
  import NimbleParsec
  alias MudPainter.XMLImporter.REXPaint

  defparsec(:parse, REXPaint.parser())

  def process(file_path) do
    {:ok, parsed_data, _, _, _, _} = File.read!(file_path) |> parse()

    parsed_data
  end
end
