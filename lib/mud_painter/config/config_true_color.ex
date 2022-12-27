defmodule MudPainter.ConfigTrueColor do
  defstruct [:foreground, :background, :reset, r: "{r}", g: "{g}", b: "{b}", base: 10]
end
