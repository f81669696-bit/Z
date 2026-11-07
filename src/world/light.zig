const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const CHUNK_W = @import("chunk.zig").CHUNK_W;
const CHUNK_H = @import("chunk.zig").CHUNK_H;
const CHUNK_D = @import("chunk.zig").CHUNK_D;
const block = @import("block.zig");

pub const LightMap = struct {
    // 4 bits sky + 4 bits block per voxel
    data: [CHUNK_W * CHUNK_H * CHUNK_D]u8,

    pub fn init() LightMap {
        return .{ .data = [_]u8{0} ** (CHUNK_W * CHUNK_H * CHUNK_D) };
    }

    inline fn idx(x: i32, y: i32, z: i32) usize {
        return @intCast(y * CHUNK_W * CHUNK_D + z * CHUNK_W + x);
    }

    pub fn getSky(self: *const LightMap, x: i32, y: i32, z: i32) u4 {
        return @intCast((self.data[idx(x,y,z)] >> 4) & 0xF);
    }

    pub fn getBlock(self: *const LightMap, x: i32, y: i32, z: i32) u4 {
        return @intCast(self.data[idx(x,y,z)] & 0xF);
    }

    pub fn set(self: *LightMap, x: i32, y: i32, z: i32, sky: u4, blk: u4) void {
        self.data[idx(x,y,z)] = (@as(u8, sky) << 4) | @as(u8, blk);
    }
};

pub fn propagateSkyLight(chunk: *const Chunk, light: *LightMap) void {
    // top-down sky light
    var x: i32 = 0;
    while (x < CHUNK_W) : (x += 1) {
        var z: i32 = 0;
        while (z < CHUNK_D) : (z += 1) {
            var sky: u4 = 15;
            var y: i32 = CHUNK_H - 1;
            while (y >= 0) : (y -= 1) {
                const bid = chunk.get(x, y, z);
                if (block.isSolid(bid) and !block.isTransparent(bid)) sky = 0;
                light.set(x, y, z, sky, 0);
            }
        }
    }
}

pub fn propagateBlockLight(chunk: *const Chunk, light: *LightMap) void {
    var x: i32 = 0;
    while (x < CHUNK_W) : (x += 1) {
        var y: i32 = 0;
        while (y < CHUNK_H) : (y += 1) {
            var z: i32 = 0;
            while (z < CHUNK_D) : (z += 1) {
                const bid = chunk.get(x, y, z);
                const def = block.getDef(bid);
                if (def.flags.light_emitting) {
                    const sky = light.getSky(x, y, z);
                    light.set(x, y, z, sky, def.light_level);
                }
            }
        }
    }
}