const std = @import("std");

pub const TagType = enum(u8) {
    end        = 0,
    byte       = 1,
    short      = 2,
    int        = 3,
    long       = 4,
    float      = 5,
    double     = 6,
    byte_array = 7,
    string     = 8,
    list       = 9,
    compound   = 10,
    int_array  = 11,
    long_array = 12,
};

pub const Tag = union(TagType) {
    end:        void,
    byte:       i8,
    short:      i16,
    int:        i32,
    long:       i64,
    float:      f32,
    double:     f64,
    byte_array: []i8,
    string:     []u8,
    list:       []Tag,
    compound:   []NamedTag,
    int_array:  []i32,
    long_array: []i64,
};

pub const NamedTag = struct {
    name: []u8,
    tag:  Tag,
};

pub fn readNamedTag(reader: anytype, allocator: std.mem.Allocator) !NamedTag {
    const type_id = try reader.readByte();
    if (type_id == 0) return NamedTag{ .name = &.{}, .tag = .end };
    const name_len = try reader.readInt(u16, .big);
    const name = try allocator.alloc(u8, name_len);
    try reader.readNoEof(name);
    const tag = try readPayload(reader, allocator, @enumFromInt(type_id));
    return NamedTag{ .name = name, .tag = tag };
}

pub fn readPayload(reader: anytype, allocator: std.mem.Allocator, tag_type: TagType) !Tag {
    return switch (tag_type) {
        .end   => Tag{ .end = {} },
        .byte  => Tag{ .byte  = try reader.readInt(i8,  .big) },
        .short => Tag{ .short = try reader.readInt(i16, .big) },
        .int   => Tag{ .int   = try reader.readInt(i32, .big) },
        .long  => Tag{ .long  = try reader.readInt(i64, .big) },
        .float => Tag{ .float = @bitCast(try reader.readInt(u32, .big)) },
        .double=> Tag{ .double= @bitCast(try reader.readInt(u64, .big)) },
        .string => blk: {
            const len = try reader.readInt(u16, .big);
            const s = try allocator.alloc(u8, len);
            try reader.readNoEof(s);
            break :blk Tag{ .string = s };
        },
        .byte_array => blk: {
            const len = try reader.readInt(i32, .big);
            const arr = try allocator.alloc(i8, @intCast(len));
            for (arr) |*b| b.* = try reader.readInt(i8, .big);
            break :blk Tag{ .byte_array = arr };
        },
        .int_array => blk: {
            const len = try reader.readInt(i32, .big);
            const arr = try allocator.alloc(i32, @intCast(len));
            for (arr) |*v| v.* = try reader.readInt(i32, .big);
            break :blk Tag{ .int_array = arr };
        },
        .long_array => blk: {
            const len = try reader.readInt(i32, .big);
            const arr = try allocator.alloc(i64, @intCast(len));
            for (arr) |*v| v.* = try reader.readInt(i64, .big);
            break :blk Tag{ .long_array = arr };
        },
        .list => blk: {
            const elem_type: TagType = @enumFromInt(try reader.readByte());
            const len = try reader.readInt(i32, .big);
            const arr = try allocator.alloc(Tag, @intCast(len));
            for (arr) |*t| t.* = try readPayload(reader, allocator, elem_type);
            break :blk Tag{ .list = arr };
        },
        .compound => blk: {
            var list = std.ArrayList(NamedTag).init(allocator);
            while (true) {
                const nt = try readNamedTag(reader, allocator);
                if (nt.tag == .end) break;
                try list.append(nt);
            }
            break :blk Tag{ .compound = try list.toOwnedSlice() };
        },
    };
}