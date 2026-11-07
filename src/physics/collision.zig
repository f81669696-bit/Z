const std = @import("std");
const Vec3 = @import("../math/vec.zig").Vec3;
const AABB = @import("../math/aabb.zig").AABB;
const Chunk = @import("../world/chunk.zig").Chunk;
const block = @import("../world/block.zig");

pub const SweepResult = struct {
    time: f32,       // 0..1 — when collision occurs
    normal: Vec3,    // face normal hit
    hit: bool,
};

// Sweep AABB through world blocks, return first collision time and normal
pub fn sweepAABB(aabb: AABB, vel: Vec3, getBlock: anytype, ctx: anytype) SweepResult {
    var result = SweepResult{ .time = 1.0, .normal = Vec3.new(0, 0, 0), .hit = false };
    if (vel.x == 0 and vel.y == 0 and vel.z == 0) return result;

    const expanded = aabb.expand(vel);
    const min_bx: i32 = @intFromFloat(@floor(expanded.min.x));
    const min_by: i32 = @intFromFloat(@floor(expanded.min.y));
    const min_bz: i32 = @intFromFloat(@floor(expanded.min.z));
    const max_bx: i32 = @intFromFloat(@ceil(expanded.max.x));
    const max_by: i32 = @intFromFloat(@ceil(expanded.max.y));
    const max_bz: i32 = @intFromFloat(@ceil(expanded.max.z));

    var bx: i32 = min_bx;
    while (bx <= max_bx) : (bx += 1) {
        var by: i32 = min_by;
        while (by <= max_by) : (by += 1) {
            var bz: i32 = min_bz;
            while (bz <= max_bz) : (bz += 1) {
                const bid = getBlock(ctx, bx, by, bz);
                if (!block.isSolid(bid)) continue;

                const block_aabb = AABB.new(
                    Vec3.new(@floatFromInt(bx), @floatFromInt(by), @floatFromInt(bz)),
                    Vec3.new(@floatFromInt(bx + 1), @floatFromInt(by + 1), @floatFromInt(bz + 1)),
                );

                const sr = sweepAABBvsAABB(aabb, vel, block_aabb);
                if (sr.hit and sr.time < result.time) {
                    result = sr;
                }
            }
        }
    }
    return result;
}

pub fn sweepAABBvsAABB(a: AABB, vel: Vec3, b: AABB) SweepResult {
    var entry = Vec3.new(-std.math.inf(f32), -std.math.inf(f32), -std.math.inf(f32));
    var exit_t = Vec3.new(std.math.inf(f32), std.math.inf(f32), std.math.inf(f32));

    if (vel.x > 0) {
        entry.x = (b.min.x - a.max.x) / vel.x;
        exit_t.x = (b.max.x - a.min.x) / vel.x;
    } else if (vel.x < 0) {
        entry.x = (b.max.x - a.min.x) / vel.x;
        exit_t.x = (b.min.x - a.max.x) / vel.x;
    }
    if (vel.y > 0) {
        entry.y = (b.min.y - a.max.y) / vel.y;
        exit_t.y = (b.max.y - a.min.y) / vel.y;
    } else if (vel.y < 0) {
        entry.y = (b.max.y - a.min.y) / vel.y;
        exit_t.y = (b.min.y - a.max.y) / vel.y;
    }
    if (vel.z > 0) {
        entry.z = (b.min.z - a.max.z) / vel.z;
        exit_t.z = (b.max.z - a.min.z) / vel.z;
    } else if (vel.z < 0) {
        entry.z = (b.max.z - a.min.z) / vel.z;
        exit_t.z = (b.min.z - a.max.z) / vel.z;
    }

    const entry_time = @max(entry.x, @max(entry.y, entry.z));
    const exit_time  = @min(exit_t.x, @min(exit_t.y, exit_t.z));

    if (entry_time > exit_time or exit_time < 0 or entry_time > 1)
        return .{ .time = 1.0, .normal = Vec3.new(0,0,0), .hit = false };

    var normal = Vec3.new(0, 0, 0);
    if (entry.x > entry.y and entry.x > entry.z) {
        normal.x = if (vel.x < 0) 1 else -1;
    } else if (entry.y > entry.z) {
        normal.y = if (vel.y < 0) 1 else -1;
    } else {
        normal.z = if (vel.z < 0) 1 else -1;
    }
    return .{ .time = entry_time, .normal = normal, .hit = true };
}