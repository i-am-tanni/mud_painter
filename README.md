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

Format files inform the color encoding patterns for output.

- See `/lib/mud_painter/config` for format fields
- See `/formats` for examples.

### Symbols

Repetitions in the symbols determine any leading zeroes if applicable.

Example:

```
If symbol = {r} and number = 10 (base 10), result will be "10"
If symbol = {rrr} and number = 10 (base 10), result will be "010"
```

**Warning**: The largest number of repetitions results in the padding number regardless of consecutiveness.
