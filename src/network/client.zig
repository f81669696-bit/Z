const std = @import("std");
const proto = @import("protocol.zig");

pub const ConnectionState = enum {
    disconnected,
    connecting,
    handshaking,
    logging_in,
    configuring,
    playing,
};

pub const ClientConfig = struct {
    host: []const u8,
    port: u16 = 25565,
    username: []const u8,
    uuid: [36]u8 = [_]u8{0} ** 36,
    access_token: []const u8 = "",
};

pub const Client = struct {
    config: ClientConfig,
    state: ConnectionState,
    stream: ?std.net.Stream,
    allocator: std.mem.Allocator,
    buf: [65536]u8,

    pub fn init(allocator: std.mem.Allocator, config: ClientConfig) Client {
        return .{
            .config = config,
            .state = .disconnected,
            .stream = null,
            .allocator = allocator,
            .buf = undefined,
        };
    }

    pub fn connect(self: *Client) !void {
        const addr = try std.net.Address.resolveIp(self.config.host, self.config.port);
        self.stream = try std.net.tcpConnectToAddress(addr);
        self.state = .handshaking;
        try self.sendHandshake();
        try self.sendLoginStart();
        self.state = .logging_in;
    }

    pub fn disconnect(self: *Client) void {
        if (self.stream) |s| {
            s.close();
            self.stream = null;
        }
        self.state = .disconnected;
    }

    fn sendHandshake(self: *Client) !void {
        var tmp: [512]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&tmp);
        const w = fbs.writer();
        try proto.writeVarInt(w, proto.PROTOCOL_VERSION);
        try proto.writeString(w, self.config.host);
        try w.writeInt(u16, self.config.port, .big);
        try proto.writeVarInt(w, 2); // next state = login
        try self.sendPacket(proto.PacketId.C2S_HANDSHAKE, fbs.getWritten());
    }

    fn sendLoginStart(self: *Client) !void {
        var tmp: [512]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&tmp);
        const w = fbs.writer();
        try proto.writeString(w, self.config.username);
        // UUID (16 bytes) — zeros for offline mode
        try w.writeAll(&[_]u8{0} ** 16);
        try self.sendPacket(proto.PacketId.C2S_LOGIN_START, fbs.getWritten());
    }

    pub fn sendKeepAlive(self: *Client, id: i64) !void {
        var tmp: [16]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&tmp);
        try fbs.writer().writeInt(i64, id, .big);
        try self.sendPacket(proto.PacketId.C2S_KEEP_ALIVE, fbs.getWritten());
    }

    fn sendPacket(self: *Client, packet_id: i32, data: []const u8) !void {
        if (self.stream == null) return error.NotConnected;
        var hdr: [16]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&hdr);
        const w = fbs.writer();
        // length prefix = varint(id) + data
        var id_buf: [5]u8 = undefined;
        var id_fbs = std.io.fixedBufferStream(&id_buf);
        try proto.writeVarInt(id_fbs.writer(), packet_id);
        const id_bytes = id_fbs.getWritten();
        const total_len: i32 = @intCast(id_bytes.len + data.len);
        try proto.writeVarInt(w, total_len);
        try self.stream.?.writer().writeAll(fbs.getWritten());
        try self.stream.?.writer().writeAll(id_bytes);
        try self.stream.?.writer().writeAll(data);
    }

    pub fn tick(self: *Client) !void {
        if (self.stream == null) return;
        // non-blocking read — poll with timeout 0
        // full async packet loop goes here in Phase 6
        _ = self;
    }
};