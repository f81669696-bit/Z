const std = @import("std");

pub const Level = enum { debug, info, warn, err };

var log_level: Level = .info;

pub fn setLevel(level: Level) void {
    log_level = level;
}

fn shouldLog(level: Level) bool {
    return @intFromEnum(level) >= @intFromEnum(log_level);
}

pub fn debug(comptime fmt: []const u8, args: anytype) void {
    if (!shouldLog(.debug)) return;
    const stderr = std.io.getStdErr().writer();
    stderr.print("[DEBUG] " ++ fmt ++ "
", args) catch {};
}

pub fn info(comptime fmt: []const u8, args: anytype) void {
    if (!shouldLog(.info)) return;
    const stderr = std.io.getStdErr().writer();
    stderr.print("[INFO]  " ++ fmt ++ "
", args) catch {};
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    if (!shouldLog(.warn)) return;
    const stderr = std.io.getStdErr().writer();
    stderr.print("[WARN]  " ++ fmt ++ "
", args) catch {};
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    if (!shouldLog(.err)) return;
    const stderr = std.io.getStdErr().writer();
    stderr.print("[ERR]   " ++ fmt ++ "
", args) catch {};
}