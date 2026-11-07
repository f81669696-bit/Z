const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const CHUNK_W = @import("chunk.zig").CHUNK_W;
const CHUNK_H = @import("chunk.zig").CHUNK_H;
const CHUNK_D = @import("chunk.zig").CHUNK_D;
const block = @import("block.zig");
const noise = @import("../util/noise.zig");

pub const GeneratorConfig = struct {
    seed: u64 = 12345,
    sea_level: i32 = 64,
    terrain_scale: f32 = 0.004,
    terrain_height: f32 = 48.0,
    base_height: f32 = 48.0,
};

pub const Generator = struct {
    config: GeneratorConfig,

    pub fn init(config: GeneratorConfig) Generator {
        return .{ .config = config };
    }

    pub fn generate(self: *const Generator, chunk: *Chunk) void {
        const wx = chunk.worldX();
        const wz = chunk.worldZ();
        const cfg = self.config;

        var x: i32 = 0;
        while (x < CHUNK_W) : (x += 1) {
            var z: i32 = 0;
            while (z < CHUNK_D) : (z += 1) {
                const fx = @as(f32, @floatFromInt(wx + x));
                const fz = @as(f32, @floatFromInt(wz + z));

                // terrain height via octave noise
                const h_norm = noise.octaves(
                    fx * cfg.terrain_scale,
                    0,
                    fz * cfg.terrain_scale,
                    6, 0.5, 2.0,
                );
                const height: i32 = @intFromFloat(cfg.base_height + h_norm * cfg.terrain_height);
                const clamped = @min(height, CHUNK_H - 1);

                var y: i32 = 0;
                while (y < CHUNK_H) : (y += 1) {
                    if (y == 0) {
                        chunk.set(x, y, z, block.STONE);
                    } else if (y < clamped - 4) {
                        chunk.set(x, y, z, block.STONE);
                    } else if (y < clamped) {
                        chunk.set(x, y, z, block.DIRT);
                    } else if (y == clamped) {
                        if (clamped <= cfg.sea_level + 1) {
                            chunk.set(x, y, z, block.SAND);
                        } else {
                            chunk.set(x, y, z, block.GRASS);
                        }
                    } else if (y <= cfg.sea_level) {
                        chunk.set(x, y, z, block.WATER);
                    }
                }

                // simple tree gen
                if (clamped > cfg.sea_level + 2) {
                    const tree_n = noise.perlin(fx * 0.3 + 1000, 0, fz * 0.3 + 1000);
                    if (tree_n > 0.6 and clamped + 6 < CHUNK_H) {
                        self.placeTree(chunk, x, clamped + 1, z);
                    }
                }
            }
        }
        chunk.generated = true;
    }

    fn placeTree(self: *const Generator, chunk: *Chunk, x: i32, y: i32, z: i32) void {
        _ = self;
        // trunk
        var i: i32 = 0;
        while (i < 5) : (i += 1) chunk.set(x, y+i, z, block.LOG);
        // leaves
        var dx: i32 = -2;
        while (dx <= 2) : (dx += 1) {
            var dz: i32 = -2;
            while (dz <= 2) : (dz += 1) {
                chunk.set(x+dx, y+3, z+dz, block.LEAVES);
                chunk.set(x+dx, y+4, z+dz, block.LEAVES);
            }
        }
        var dx2: i32 = -1;
        while (dx2 <= 1) : (dx2 += 1) {
            var dz2: i32 = -1;
            while (dz2 <= 1) : (dz2 += 1) {
                chunk.set(x+dx2, y+5, z+dz2, block.LEAVES);
            }
        }
        chunk.set(x, y+5, z, block.LEAVES);
    }
};