const std = @import("std");

pub const Profile = struct {
    username: [32]u8,
    uuid: [36]u8,
    access_token: [512]u8,
    offline: bool,
    last_server: [256]u8,
    render_distance: u8,
    fov: f32,
    sensitivity: f32,

    pub fn default() Profile {
        var p: Profile = undefined;
        @memset(&p.username, 0);
        @memset(&p.uuid, 0);
        @memset(&p.access_token, 0);
        @memset(&p.last_server, 0);
        p.offline = true;
        p.render_distance = 8;
        p.fov = 70.0;
        p.sensitivity = 0.5;
        return p;
    }

    pub fn save(self: *const Profile, path: []const u8) !void {
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();
        try file.writer().writeAll(std.mem.asBytes(self));
    }

    pub fn load(path: []const u8) !Profile {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();
        var p: Profile = undefined;
        const n = try file.reader().readAll(std.mem.asBytes(&p));
        if (n != @sizeOf(Profile)) return error.InvalidProfile;
        return p;
    }

    pub fn getUsername(self: *const Profile) []const u8 {
        const len = std.mem.indexOfScalar(u8, &self.username, 0) orelse self.username.len;
        return self.username[0..len];
    }
};