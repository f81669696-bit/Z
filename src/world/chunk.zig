const std = @import("std");
const block = @import("block.zig");

pub const CHUNK_W: i32 = 16;
pub const CHUNK_H: i32 = 256;
pub const CHUNK_D: i32 = 16;
pub const CHUNK_SIZE: usize = @intCast(CHUNK_W * CHUNK_H * CHUNK_D);

pub const ChunkPos = struct {
    x: i32,
    z: i32,

    pub fn fromWorld(wx: i32, wz: i32) ChunkPos {
        return .{
            .x = @divFloor(wx, CHUNK_W),
            .z = @divFloor(wz, CHUNK_D),
        };
    }

    pub fn eql(a: ChunkPos, b: ChunkPos) bool {
        return a.x == b.x and a.z == b.z;
    }
};

pub const Chunk = struct {
    pos: ChunkPos,
    blocks: [CHUNK_SIZE]block.BlockId,
    dirty: bool,
    generated: bool,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, pos: ChunkPos) !*Chunk {
        const self = try allocator.create(Chunk);
        self.* = .{
            .pos = pos,
            .blocks = [_]block.BlockId{block.AIR} ** CHUNK_SIZE,
            .dirty = true,
            .generated = false,
            .allocator = allocator,
        };
        return self;
    }

    pub fn deinit(self: *Chunk) void {
        self.allocator.destroy(self);
    }

    inline fn idx(x: i32, y: i32, z: i32) usize {
        return @intCast(y * CHUNK_W * CHUNK_D + z * CHUNK_W + x);
    }

    pub fn get(self: *const Chunk, x: i32, y: i32, z: i32) block.BlockId {
        if (x < 0 or x >= CHUNK_W or y < 0 or y >= CHUNK_H or z < 0 or z >= CHUNK_D)
            return block.AIR;
        return self.blocks[idx(x, y, z)];
    }

    pub fn set(self: *Chunk, x: i32, y: i32, z: i32, id: block.BlockId) void {
        if (x < 0 or x >= CHUNK_W or y < 0 or y >= CHUNK_H or z < 0 or z >= CHUNK_D)
            return;
        self.blocks[idx(x, y, z)] = id;
        self.dirty = true;
    }

    pub fn worldX(self: *const Chunk) i32 {
        return self.pos.x * CHUNK_W;
    }

    pub fn worldZ(self: *const Chunk) i32 {
        return self.pos.z * CHUNK_D;
    }
};