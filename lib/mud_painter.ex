defmodule MudPainter do
  alias MudPainter.ConfigImporter
  alias MudPainter.Converter

  def run(xml_path, config_path) do
    config = ConfigImporter.run(config_path)
    Converter.run(xml_path, config)
  end

  def example() do
    run("data/test.xml", "formats/ansi_true_color.json")
  end
end
