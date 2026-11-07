const std = @import("std");

pub const BlockId = u16;

pub const BlockFace = enum(u8) {
    top = 0, bottom, north, south, east, west, count,
};

pub const BlockFlags = packed struct {
    solid: bool = false,
    transparent: bool = false,
    liquid: bool = false,
    light_emitting: bool = false,
    _pad: u4 = 0,
};

pub const BlockDef = struct {
    id: BlockId,
    name: []const u8,
    flags: BlockFlags,
    tex: [6]u16, // texture index per face
    light_level: u4 = 0,
};

pub const AIR:   BlockId = 0;
pub const STONE: BlockId = 1;
pub const GRASS: BlockId = 2;
pub const DIRT:  BlockId = 3;
pub const WOOD:  BlockId = 4;
pub const SAND:  BlockId = 5;
pub const WATER: BlockId = 6;
pub const GLASS: BlockId = 7;
pub const LOG:   BlockId = 8;
pub const LEAVES:BlockId = 9;
pub const TORCH: BlockId = 10;

pub const BLOCK_DEFS = [_]BlockDef{
    .{ .id = AIR,    .name = "air",    .flags = .{ .transparent = true }, .tex = [_]u16{0}**6 },
    .{ .id = STONE,  .name = "stone",  .flags = .{ .solid = true },        .tex = [_]u16{1}**6 },
    .{ .id = GRASS,  .name = "grass",  .flags = .{ .solid = true },        .tex = [_]u16{3,2,4,4,4,4} },
    .{ .id = DIRT,   .name = "dirt",   .flags = .{ .solid = true },        .tex = [_]u16{2}**6 },
    .{ .id = WOOD,   .name = "wood",   .flags = .{ .solid = true },        .tex = [_]u16{5}**6 },
    .{ .id = SAND,   .name = "sand",   .flags = .{ .solid = true },        .tex = [_]u16{6}**6 },
    .{ .id = WATER,  .name = "water",  .flags = .{ .liquid = true, .transparent = true }, .tex = [_]u16{7}**6 },
    .{ .id = GLASS,  .name = "glass",  .flags = .{ .solid = true, .transparent = true },  .tex = [_]u16{8}**6 },
    .{ .id = LOG,    .name = "log",    .flags = .{ .solid = true },        .tex = [_]u16{9,9,10,10,10,10} },
    .{ .id = LEAVES, .name = "leaves", .flags = .{ .solid = true, .transparent = true },  .tex = [_]u16{11}**6 },
    .{ .id = TORCH,  .name = "torch",  .flags = .{ .light_emitting = true },.tex = [_]u16{12}**6, .light_level = 14 },
};

pub fn getDef(id: BlockId) BlockDef {
    if (id < BLOCK_DEFS.len) return BLOCK_DEFS[id];
    return BLOCK_DEFS[0];
}

pub fn isSolid(id: BlockId) bool {
    return getDef(id).flags.solid;
}

pub fn isTransparent(id: BlockId) bool {
    return getDef(id).flags.transparent;
}

pub fn isLiquid(id: BlockId) bool {
    return getDef(id).flags.liquid;
}