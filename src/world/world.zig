const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const ChunkPos = @import("chunk.zig").ChunkPos;
const CHUNK_W = @import("chunk.zig").CHUNK_W;
const CHUNK_H = @import("chunk.zig").CHUNK_H;
const CHUNK_D = @import("chunk.zig").CHUNK_D;
const Generator = @import("generator.zig").Generator;
const GeneratorConfig = @import("generator.zig").GeneratorConfig;
const block = @import("block.zig");
const Vec3 = @import("../math/vec.zig").Vec3;

pub const World = struct {
    chunks: std.AutoHashMap(u64, *Chunk),
    generator: Generator,
    allocator: std.mem.Allocator,
    render_distance: i32,

    pub fn init(allocator: std.mem.Allocator, seed: u64, render_distance: i32) World {
        return .{
            .chunks = std.AutoHashMap(u64, *Chunk).init(allocator),
            .generator = Generator.init(.{ .seed = seed }),
            .allocator = allocator,
            .render_distance = render_distance,
        };
    }

    pub fn deinit(self: *World) void {
        var it = self.chunks.valueIterator();
        while (it.next()) |chunk| chunk.*.deinit();
        self.chunks.deinit();
    }

    fn chunkKey(pos: ChunkPos) u64 {
        const x: u64 = @bitCast(@as(i64, pos.x));
        const z: u64 = @bitCast(@as(i64, pos.z));
        return (x << 32) | (z & 0xFFFFFFFF);
    }

    pub fn getChunk(self: *World, pos: ChunkPos) ?*Chunk {
        return self.chunks.get(chunkKey(pos));
    }

    pub fn loadChunk(self: *World, pos: ChunkPos) !*Chunk {
        const key = chunkKey(pos);
        if (self.chunks.get(key)) |c| return c;
        const chunk = try Chunk.init(self.allocator, pos);
        self.generator.generate(chunk);
        try self.chunks.put(key, chunk);
        return chunk;
    }

    pub fn getBlock(self: *World, wx: i32, wy: i32, wz: i32) block.BlockId {
        const cp = ChunkPos.fromWorld(wx, wz);
        const chunk = self.getChunk(cp) orelse return block.AIR;
        const lx = @mod(wx, CHUNK_W);
        const lz = @mod(wz, CHUNK_D);
        return chunk.get(lx, wy, lz);
    }

    pub fn setBlock(self: *World, wx: i32, wy: i32, wz: i32, id: block.BlockId) void {
        const cp = ChunkPos.fromWorld(wx, wz);
        const chunk = self.getChunk(cp) orelse return;
        const lx = @mod(wx, CHUNK_W);
        const lz = @mod(wz, CHUNK_D);
        chunk.set(lx, wy, lz, id);
    }

    pub fn updateChunksAround(self: *World, pos: Vec3) !void {
        const cx: i32 = @intFromFloat(@divFloor(pos.x, @as(f32, @floatFromInt(CHUNK_W))));
        const cz: i32 = @intFromFloat(@divFloor(pos.z, @as(f32, @floatFromInt(CHUNK_D))));
        var dx: i32 = -self.render_distance;
        while (dx <= self.render_distance) : (dx += 1) {
            var dz: i32 = -self.render_distance;
            while (dz <= self.render_distance) : (dz += 1) {
                const cp = ChunkPos{ .x = cx + dx, .z = cz + dz };
                _ = try self.loadChunk(cp);
            }
        }
    }
};