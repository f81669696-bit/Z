const std = @import("std");
const math = @import("math/vec.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Cube v0.1 starting...
", .{});

    const v = math.Vec3.new(1.0, 2.0, 3.0);
    try stdout.print("Vec3: {d} {d} {d}
", .{ v.x, v.y, v.z });
}