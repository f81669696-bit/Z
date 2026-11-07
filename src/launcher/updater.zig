const std = @import("std");

pub const VersionInfo = struct {
    version: [32]u8,
    url: [512]u8,
    size: u64,
    sha256: [64]u8,
};

pub const Updater = struct {
    allocator: std.mem.Allocator,
    current_version: []const u8,

    pub const CURRENT_VERSION = "0.1.0";
    // FILL: replace with actual update server URL
    pub const UPDATE_URL = "https://your-update-server/cube/version.json";

    pub fn init(allocator: std.mem.Allocator) Updater {
        return .{
            .allocator = allocator,
            .current_version = CURRENT_VERSION,
        };
    }

    // Check for updates — returns true if update available
    // FILL: implement HTTP GET to UPDATE_URL, parse JSON response
    pub fn checkForUpdate(self: *Updater) !bool {
        _ = self;
        return false; // offline until update server is set up
    }

    pub fn getCurrentVersion(self: *const Updater) []const u8 {
        return self.current_version;
    }
};