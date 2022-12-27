# MudPainter

## Description

A tool for converting REXPaint XML files to a custom color-encoded format.

Useful for MUDs and other text-based applications with custom color encodings.

## To Use

In the terminal `cd` to the cloned directory and enter the following inputs:

```
> iex -S mix
> MudPainter.run("path/to/xml_file.xml", "path/to/format_file.json")
```

## Formats

Formats are provided as json and a few examples are contained in the folder: `MudPainter/formats`

Repetitions in the symbols determine any leading zeroes if applicable.

**Warning**: The largest number of repetitions results in the padding number.
Does NOT consider consecutivity

Example:

```
If symbol = {r}, number = 0, result will be "0"
If symbol = {rr}, number = 0, result will be "00"
```

Considered color modes are:

- TrueColor 24 bit
- 256 colors
- 16 colors

See `lib/mud_painter/config` for format fields and `/formats` for examples
