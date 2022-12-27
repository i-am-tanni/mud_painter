# MudPainter

## Description

A tool for quick export of REXPaint XML files to a custom encoded format.

Supported color modes:

- TrueColor 24 bit
- xterm 256
- 16 colors

## To Use

In the terminal `cd` to the cloned directory and enter the following inputs:

```
> iex -S mix
> MudPainter.run("path/to/xml_file.xml", "path/to/format_file.json")
```

## Formats

Formats are provided as json.

Format files inform the custom encoding patterns for the output.

See `/lib/mud_painter/config` for format fields and `/formats` for examples.

### Symbols

Repetitions in the symbols determine any leading zeroes if applicable.

**Warning**: The largest number of repetitions results in the padding number.
Consecutivness is not considered.

Example:

```
If symbol = {r}, number = 0, result will be "0"
If symbol = {rr}, number = 0, result will be "00"
```
