const std = @import("std");

pub const AuthMode = enum { offline, xbox };

pub const AuthResult = struct {
    username: [32]u8,
    uuid: [36]u8,
    access_token: [512]u8,
    mode: AuthMode,
};

pub const Auth = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Auth {
        return .{ .allocator = allocator };
    }

    // Offline mode — no network needed
    pub fn loginOffline(self: *Auth, username: []const u8) !AuthResult {
        _ = self;
        var result: AuthResult = undefined;
        result.mode = .offline;
        // zero buffers
        @memset(&result.username, 0);
        @memset(&result.uuid, 0);
        @memset(&result.access_token, 0);
        const copy_len = @min(username.len, result.username.len - 1);
        @memcpy(result.username[0..copy_len], username[0..copy_len]);
        // deterministic offline UUID from username hash
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(username);
        const h = hasher.final();
        _ = std.fmt.bufPrint(&result.uuid, "{x:0>8}-{x:0>4}-{x:0>4}-{x:0>4}-{x:0>12}", .{
            @as(u32, @truncate(h >> 32)),
            @as(u16, @truncate(h >> 16)),
            @as(u16, @truncate(h)),
            @as(u16, @truncate(h >> 48)),
            @as(u48, @truncate(h)),
        }) catch {};
        return result;
    }

    // Xbox Live auth — requires Microsoft OAuth
    // FILL: implement OAuth2 device code flow to get Xbox token
    // Endpoints:
    //   https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode
    //   https://login.microsoftonline.com/consumers/oauth2/v2.0/token
    //   https://user.auth.xboxlive.com/user/authenticate
    //   https://xsts.auth.xboxlive.com/xsts/authorize
    //   https://api.minecraftservices.com/authentication/login_with_xbox
    //   https://api.minecraftservices.com/minecraft/profile
    pub fn loginXbox(self: *Auth) !AuthResult {
        _ = self;
        // placeholder until OAuth is wired
        return error.NotImplemented;
    }
};