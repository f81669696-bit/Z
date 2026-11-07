const std = @import("std");

const perm: [512]u8 = blk: {
    const p = [256]u8{
        151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,
        140,36,103,30,69,142,8,99,37,240,21,10,23,190,6,148,
        247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,
        57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,
        74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,
        60,211,133,230,220,105,92,41,55,46,245,40,244,102,143,54,
        65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,
        200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,
        52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,212,
        207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,
        119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,
        129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,
        218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241,
        81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,157,
        184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,
        222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,
    };
    var result: [512]u8 = undefined;
    var i: usize = 0;
    while (i < 256) : (i += 1) {
        result[i] = p[i];
        result[i + 256] = p[i];
    }
    break :blk result;
};

fn fade(t: f32) f32 {
    return t * t * t * (t * (t * 6 - 15) + 10);
}

fn lerp(t: f32, a: f32, b: f32) f32 {
    return a + t * (b - a);
}

fn grad(hash: u8, x: f32, y: f32, z: f32) f32 {
    const h = hash & 15;
    const u: f32 = if (h < 8) x else y;
    const v: f32 = if (h < 4) y else if (h == 12 or h == 14) x else z;
    return (if ((h & 1) == 0) u else -u) + (if ((h & 2) == 0) v else -v);
}

pub fn perlin(x: f32, y: f32, z: f32) f32 {
    const xi: u8 = @intCast(@as(i32, @intFromFloat(@floor(x))) & 255);
    const yi: u8 = @intCast(@as(i32, @intFromFloat(@floor(y))) & 255);
    const zi: u8 = @intCast(@as(i32, @intFromFloat(@floor(z))) & 255);
    const xf = x - @floor(x);
    const yf = y - @floor(y);
    const zf = z - @floor(z);
    const u = fade(xf);
    const v = fade(yf);
    const w = fade(zf);
    const a   = perm[xi] +% yi;
    const aa  = perm[a] +% zi;
    const ab  = perm[a +% 1] +% zi;
    const b   = perm[xi +% 1] +% yi;
    const ba  = perm[b] +% zi;
    const bb  = perm[b +% 1] +% zi;
    return lerp(w,
        lerp(v,
            lerp(u, grad(perm[aa],     xf,   yf,   zf),
                    grad(perm[ba],     xf-1, yf,   zf)),
            lerp(u, grad(perm[ab],     xf,   yf-1, zf),
                    grad(perm[bb],     xf-1, yf-1, zf))),
        lerp(v,
            lerp(u, grad(perm[aa +% 1], xf,   yf,   zf-1),
                    grad(perm[ba +% 1], xf-1, yf,   zf-1)),
            lerp(u, grad(perm[ab +% 1], xf,   yf-1, zf-1),
                    grad(perm[bb +% 1], xf-1, yf-1, zf-1))));
}

pub fn octaves(x: f32, y: f32, z: f32, octs: u32, persistence: f32, lacunarity: f32) f32 {
    var result: f32 = 0;
    var amplitude: f32 = 1;
    var frequency: f32 = 1;
    var max_val: f32 = 0;
    var i: u32 = 0;
    while (i < octs) : (i += 1) {
        result += perlin(x * frequency, y * frequency, z * frequency) * amplitude;
        max_val += amplitude;
        amplitude *= persistence;
        frequency *= lacunarity;
    }
    return result / max_val;
}