# MudPainter

## Description

Converts REXPaint XML ascii-art files to a custom format with downsampling.

Useful for MUDs and other text based applications.

Supported color modes:

- TrueColor 24 bit
- xterm 256
- 16 colors

## To Use

In the terminal `cd` to the cloned directory and enter the following input:

```
$ _build/prod/rel/mud_painter/bin/mud_painter eval "MudPainter.run(~s(path/to/xml_file.xml), ~s(path/to/format_file.json)"
```

Example:

```
$ _build/prod/rel/mud_painter/bin/mud_painter eval "MudPainter.run(~s(data/test.xml), ~s(formats/leu.json))"
  Success! "data/test.txt" created.
```

## Formats

Formats are provided as json.

Format files inform the color encoding patterns for output.

- See `/formats` for examples
- See `/lib/mud_painter/config` for format fields

### Symbols

Repetitions in the symbols determine any leading zeroes if applicable.

Example:

```
If symbol = {r} and number = 10 (base 10), result will be "10"
If symbol = {rrr} and number = 10 (base 10), result will be "010"
```
