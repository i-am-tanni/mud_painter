// $OpenBSD$

//
// Copyright (c) 2008 Nicholas Marriott <nicholas.marriott@gmail.com>
// Copyright (c) 2016 Avi Halachmi <avihpit@yahoo.com>
//
// Permission to use, copy, modify, and distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
// IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
// OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

// Sourced from Tmux colour.c

fn colour_dist_sq(r1: i32, g1: i32, b1: i32, r2: i32, g2: i32, b2: i32) -> i32 {
    (r1 - r2) * (r1 - r2) + (g1 - g2) * (g1 - g2) + (b1 - b2) * (b1 - b2)
}

fn colour_to_6cube(v: i32) -> i32 {
    if v < 48 {
        0
    } else if v < 114 {
        1
    } else {
        (v - 35) / 40
    }
}

// Convert an RGB triplet to the xterm(1) 256 colour palette.

// xterm provides a 6x6x6 colour cube (16 - 231) and 24 greys (232 - 255). We
// map our RGB colour to the closest in the cube, also work out the closest
// grey, and use the nearest of the two.

// Note that the xterm has much lower resolution for darker colours (they are
// not evenly spread out), so our 6 levels are not evenly spread: 0x0, 0x5f
// (95), 0x87 (135), 0xaf (175), 0xd7 (215) and 0xff (255). Greys are more
// evenly spread (8, 18, 28 ... 238).

#[rustler::nif]
fn rgb_to_color256(r: i32, g: i32, b: i32) -> i32 {
    const Q2C: [i32; 6] = [0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff];

    let qr = colour_to_6cube(r);
    let cr = Q2C[qr as usize];
    let qg = colour_to_6cube(g);
    let cg = Q2C[qg as usize];
    let qb = colour_to_6cube(b);
    let cb = Q2C[qb as usize];

    if cr == r && cg == g && cb == b {
        return 16 + (36 * qr) + (6 * qg) + qb;
    }

    let grey_avg: i32 = (r + g + b) / 3;
    let grey_idx = if grey_avg > 238 {
        23
    } else {
        (grey_avg - 3) / 10
    };
    let grey = 8 + (10 * grey_idx);

    // Is grey or 6x6x6 colour closest?
    let d = colour_dist_sq(cr, cg, cb, r, g, b);
    let idx = if colour_dist_sq(grey, grey, grey, r, g, b) < d {
        232 + grey_idx
    } else {
        16 + (36 * qr) + (6 * qg) + qb
    };
    idx
}

rustler::init!("Elixir.MudPainter.Converter.Downsample", [rgb_to_color256]);
