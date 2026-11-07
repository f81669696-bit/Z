const std = @import("std");

pub const Level = enum { debug, info, warn, err };

var log_level: Level = .info;

pub fn setLevel(level: Level) void {
    log_level = level;
}

fn shouldLog(level: Level) bool {
    return @intFromEnum(level) >= @intFromEnum(log_level);
}

fn print(comptime prefix: []const u8, comptime fmt: []const u8, args: anytype) void {
    const w = std.io.getStdErr().writer();
    w.print(prefix, .{}) catch {};
    w.print(fmt, args) catch {};
    w.writeByte('\n') catch {};
}

pub fn debug(comptime fmt: []const u8, args: anytype) void {
    if (!shouldLog(.debug)) return;
    print("[DEBUG] ", fmt, args);
}

pub fn info(comptime fmt: []const u8, args: anytype) void {
    if (!shouldLog(.info)) return;
    print("[INFO]  ", fmt, args);
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    if (!shouldLog(.warn)) return;
    print("[WARN]  ", fmt, args);
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    if (!shouldLog(.err)) return;
    print("[ERR]   ", fmt, args);
}
