const std = @import("std");

// Minecraft Java Edition 26.2 protocol
// Protocol ID: based on wiki.vg/Protocol

pub const PROTOCOL_VERSION: i32 = 775; // 26.1.2 / 26.2

pub const State = enum(u8) {
    handshaking = 0,
    status      = 1,
    login       = 2,
    configuration = 3,
    play        = 4,
};

pub const PacketId = struct {
    // Serverbound handshaking
    pub const C2S_HANDSHAKE: i32 = 0x00;

    // Serverbound login
    pub const C2S_LOGIN_START:    i32 = 0x00;
    pub const C2S_ENCRYPTION_RESP:i32 = 0x01;
    pub const C2S_LOGIN_ACK:      i32 = 0x03;

    // Clientbound login
    pub const S2C_DISCONNECT_LOGIN:   i32 = 0x00;
    pub const S2C_ENCRYPTION_REQUEST: i32 = 0x01;
    pub const S2C_LOGIN_SUCCESS:      i32 = 0x02;
    pub const S2C_SET_COMPRESSION:    i32 = 0x03;

    // Serverbound play
    pub const C2S_CONFIRM_TELEPORT:   i32 = 0x00;
    pub const C2S_CHAT_MESSAGE:       i32 = 0x06;
    pub const C2S_PLAYER_SESSION:     i32 = 0x06;
    pub const C2S_MOVE_PLAYER_POS:    i32 = 0x1A;
    pub const C2S_MOVE_PLAYER_POS_ROT:i32 = 0x1B;
    pub const C2S_MOVE_PLAYER_ROT:    i32 = 0x1C;
    pub const C2S_PLAYER_COMMAND:     i32 = 0x25;
    pub const C2S_SWING_ARM:          i32 = 0x36;
    pub const C2S_USE_ITEM_ON:        i32 = 0x3E;
    pub const C2S_PLAYER_ACTION:      i32 = 0x24;
    pub const C2S_KEEP_ALIVE:         i32 = 0x18;

    // Clientbound play
    pub const S2C_BUNDLE_DELIMITER:   i32 = 0x00;
    pub const S2C_SPAWN_ENTITY:       i32 = 0x01;
    pub const S2C_LOGIN:              i32 = 0x2B;
    pub const S2C_CHUNK_DATA:         i32 = 0x27;
    pub const S2C_PLAYER_POS_LOOK:    i32 = 0x40;
    pub const S2C_DISCONNECT_PLAY:    i32 = 0x1D;
    pub const S2C_KEEP_ALIVE:         i32 = 0x26;
    pub const S2C_CHAT_MESSAGE:       i32 = 0x1C;
    pub const S2C_SET_HEALTH:         i32 = 0x5A;
    pub const S2C_GAME_EVENT:         i32 = 0x22;
};

// VarInt encoding — used throughout MC protocol
pub fn writeVarInt(writer: anytype, value: i32) !void {
    var v: u32 = @bitCast(value);
    while (true) {
        if (v & ~@as(u32, 0x7F) == 0) {
            try writer.writeByte(@intCast(v));
            return;
        }
        try writer.writeByte(@intCast((v & 0x7F) | 0x80));
        v >>= 7;
    }
}

pub fn readVarInt(reader: anytype) !i32 {
    var result: u32 = 0;
    var shift: u5 = 0;
    while (true) {
        const b = try reader.readByte();
        result |= @as(u32, b & 0x7F) << shift;
        if (b & 0x80 == 0) break;
        shift += 7;
        if (shift >= 35) return error.VarIntTooBig;
    }
    return @bitCast(result);
}

pub fn writeString(writer: anytype, s: []const u8) !void {
    try writeVarInt(writer, @intCast(s.len));
    try writer.writeAll(s);
}

pub fn readString(reader: anytype, buf: []u8) ![]u8 {
    const len = try readVarInt(reader);
    if (len < 0 or len > buf.len) return error.StringTooLong;
    const ulen: usize = @intCast(len);
    try reader.readNoEof(buf[0..ulen]);
    return buf[0..ulen];
}