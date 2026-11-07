const std = @import("std");
const gl = @import("gl.zig");

// Texture atlas — 2D array texture, one layer per block texture
// 16x16 pixels per tile, up to 256 tiles
pub const TILE_SIZE: u32 = 16;
pub const MAX_TILES: u32 = 256;

pub const TextureAtlas = struct {
    id: gl.GLuint,
    tile_count: u32,

    pub fn init() TextureAtlas {
        var id: gl.GLuint = 0;
        gl.genTextures(1, @ptrCast(&id));
        gl.bindTexture(gl.TEXTURE_2D_ARRAY, id);
        gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, @intCast(gl.NEAREST));
        gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, @intCast(gl.NEAREST));
        gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, @intCast(gl.CLAMP_TO_EDGE));
        gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, @intCast(gl.CLAMP_TO_EDGE));
        // allocate storage for all tiles
        gl.texImage3D(gl.TEXTURE_2D_ARRAY, 0, @intCast(gl.RGBA8),
            @intCast(TILE_SIZE), @intCast(TILE_SIZE), @intCast(MAX_TILES),
            0, gl.RGBA, gl.UNSIGNED_BYTE, null);
        return .{ .id = id, .tile_count = 0 };
    }

    // Upload one 16x16 RGBA tile at given index
    pub fn uploadTile(self: *TextureAtlas, index: u32, rgba: []const u8) void {
        std.debug.assert(rgba.len == TILE_SIZE * TILE_SIZE * 4);
        gl.bindTexture(gl.TEXTURE_2D_ARRAY, self.id);
        gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
        gl.texSubImage3D(gl.TEXTURE_2D_ARRAY, 0,
            0, 0, @intCast(index),
            @intCast(TILE_SIZE), @intCast(TILE_SIZE), 1,
            gl.RGBA, gl.UNSIGNED_BYTE, rgba.ptr);
        if (index + 1 > self.tile_count) self.tile_count = index + 1;
    }

    pub fn bind(self: *const TextureAtlas, slot: u32) void {
        gl.activeTexture(gl.TEXTURE0 + slot);
        gl.bindTexture(gl.TEXTURE_2D_ARRAY, self.id);
    }
};
