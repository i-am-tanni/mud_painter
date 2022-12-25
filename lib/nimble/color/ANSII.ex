defmodule Nimble.Color.ANSII do
  @moduledoc """
  Converts rgb or xterm 256 color code to requested ANSII escape code.
  Downsamples as needed.
  """

  import Bitwise
  use Rustler, otp_app: :nimble, crate: "color"

  @c256to16_table {
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    0,
    4,
    4,
    4,
    12,
    12,
    2,
    6,
    4,
    4,
    12,
    12,
    2,
    2,
    6,
    4,
    12,
    12,
    2,
    2,
    2,
    6,
    12,
    12,
    10,
    10,
    10,
    10,
    14,
    12,
    10,
    10,
    10,
    10,
    10,
    14,
    1,
    5,
    4,
    4,
    12,
    12,
    3,
    8,
    4,
    4,
    12,
    12,
    2,
    2,
    6,
    4,
    12,
    12,
    2,
    2,
    2,
    6,
    12,
    12,
    10,
    10,
    10,
    10,
    14,
    12,
    10,
    10,
    10,
    10,
    10,
    14,
    1,
    1,
    5,
    4,
    12,
    12,
    1,
    1,
    5,
    4,
    12,
    12,
    3,
    3,
    8,
    4,
    12,
    12,
    2,
    2,
    2,
    6,
    12,
    12,
    10,
    10,
    10,
    10,
    14,
    12,
    10,
    10,
    10,
    10,
    10,
    14,
    1,
    1,
    1,
    5,
    12,
    12,
    1,
    1,
    1,
    5,
    12,
    12,
    1,
    1,
    1,
    5,
    12,
    12,
    3,
    3,
    3,
    7,
    12,
    12,
    10,
    10,
    10,
    10,
    14,
    12,
    10,
    10,
    10,
    10,
    10,
    14,
    9,
    9,
    9,
    9,
    13,
    12,
    9,
    9,
    9,
    9,
    13,
    12,
    9,
    9,
    9,
    9,
    13,
    12,
    9,
    9,
    9,
    9,
    13,
    12,
    11,
    11,
    11,
    11,
    7,
    12,
    10,
    10,
    10,
    10,
    10,
    14,
    9,
    9,
    9,
    9,
    9,
    13,
    9,
    9,
    9,
    9,
    9,
    13,
    9,
    9,
    9,
    9,
    9,
    13,
    9,
    9,
    9,
    9,
    9,
    13,
    9,
    9,
    9,
    9,
    9,
    13,
    11,
    11,
    11,
    11,
    11,
    15,
    0,
    0,
    0,
    0,
    0,
    0,
    8,
    8,
    8,
    8,
    8,
    8,
    7,
    7,
    7,
    7,
    7,
    7,
    15,
    15,
    15,
    15,
    15,
    15
  }

  def to_color16(term) do
    case term do
      {:truecolor, {ground, [r, g, b]}} ->
        code256 = rgb_to_color256(r, g, b)
        to_color16({:color256, {ground, code256}})

      {:color256, {ground, code256}} ->
        code16 = color256_to_code16(code256, ground)
        "\e[#{code16}m"
    end
  end

  def color256_to_code16(code256, ground) do
    code256
    |> color256_to_color16()
    |> low_or_high_intensity()
    |> foreground_or_background(ground)
  end

  # Converts rgb or 256 color to a 16 color code (4bit).
  def color256_to_color16(code256) do
    elem(@c256to16_table, code256)
  end

  defp low_or_high_intensity(code16) do
    cond do
      # codes 30 - 37 = low intensity
      code16 < 8 -> code16 + 30
      # codes 90 - 97 = high intensity
      code16 < 16 -> code16 + 82
    end
  end

  defp foreground_or_background(code16, ground) do
    case ground do
      :foreground -> code16
      :background -> code16 + 10
    end
  end

  @doc """
  Converts rgb or 256 color code to 256 color ANSII escape code (8bit)
  """
  def to_color256(term) do
    case term do
      {:truecolor, {ground, [r, g, b]}} ->
        code256 = rgb_to_color256(r, g, b)
        to_color256({:color256, {ground, code256}})

      {:color256, {ground, code256}} ->
        ground = ground_code(ground)
        "\e[#{ground};5;#{code256}m"
    end
  end

  @doc """
  Converts rgb to true color ANSII escape code (24bit)
  """
  def to_truecolor({:truecolor, {ground, [r, g, b]}}) do
    ground = ground_code(ground)
    "\e[#{ground};2;#{r};#{g};#{b}m"
  end

  def ground_code(code) do
    case code do
      :foreground -> 38
      :background -> 48
    end
  end

  # nif - see native/color/src/lib.rs for source
  # for error handling in case the nif is not loaded
  def rgb_to_color256(_r, _g, _b), do: error()
  defp error(), do: :erlang.nif_error(:nif_not_loaded)
end
