const std = @import("std");
const Profile = @import("profile.zig").Profile;
const Auth = @import("auth.zig").Auth;
const AuthMode = @import("auth.zig").AuthMode;
const Updater = @import("updater.zig").Updater;

pub const LauncherState = enum {
    login_screen,
    main_screen,
    server_list,
    launching,
};

pub const ServerEntry = struct {
    name: [64]u8,
    address: [256]u8,
    port: u16,
};

pub const Launcher = struct {
    profile: Profile,
    auth: Auth,
    updater: Updater,
    state: LauncherState,
    servers: std.ArrayList(ServerEntry),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Launcher {
        return .{
            .profile = Profile.default(),
            .auth = Auth.init(allocator),
            .updater = Updater.init(allocator),
            .state = .login_screen,
            .servers = std.ArrayList(ServerEntry).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Launcher) void {
        self.servers.deinit();
    }

    pub fn loginOffline(self: *Launcher, username: []const u8) !void {
        const result = try self.auth.loginOffline(username);
        @memcpy(&self.profile.username, &result.username);
        @memcpy(&self.profile.uuid, &result.uuid);
        self.profile.offline = true;
        self.state = .main_screen;
    }

    pub fn addServer(self: *Launcher, name: []const u8, address: []const u8, port: u16) !void {
        var entry: ServerEntry = undefined;
        @memset(&entry.name, 0);
        @memset(&entry.address, 0);
        entry.port = port;
        const nl = @min(name.len, entry.name.len - 1);
        const al = @min(address.len, entry.address.len - 1);
        @memcpy(entry.name[0..nl], name[0..nl]);
        @memcpy(entry.address[0..al], address[0..al]);
        try self.servers.append(entry);
    }

    pub fn getVersion(self: *const Launcher) []const u8 {
        return self.updater.getCurrentVersion();
    }
};