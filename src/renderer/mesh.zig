const std = @import("std");
const gl = @import("gl.zig");

// Packed vertex format: 32 bits per vertex
// bits  0-4:  x (0-31)
// bits  5-12: y (0-255)
// bits 13-17: z (0-31)
// bits 18:    u (0-1)
// bits 19:    v (0-1)
// bits 20-27: texture index (0-255)
// bits 28-31: light level (0-15)

pub fn packVertex(x: u5, y: u8, z: u5, u: u1, v: u1, tex: u8, light: u4) u32 {
    return @as(u32, x) |
           (@as(u32, y)     << 5)  |
           (@as(u32, z)     << 13) |
           (@as(u32, u)     << 18) |
           (@as(u32, v)     << 19) |
           (@as(u32, tex)   << 20) |
           (@as(u32, light) << 28);
}

pub const Mesh = struct {
    vao: gl.GLuint,
    vbo: gl.GLuint,
    ebo: gl.GLuint,
    vertex_count: u32,
    index_count: u32,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Mesh {
        var ids: [3]gl.GLuint = undefined;
        gl.genVertexArrays(1, ids[0..1]);
        gl.genBuffers(2, ids[1..3]);

        gl.bindVertexArray(ids[0]);
        gl.bindBuffer(gl.ARRAY_BUFFER, ids[1]);
        gl.enableVertexAttribArray(0);
        // attrib 0: 1x uint packed
        gl.vertexAttribIPointer(0, 1, gl.UNSIGNED_INT, @sizeOf(u32), 0);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ids[2]);
        gl.bindVertexArray(0);

        return .{
            .vao = ids[0],
            .vbo = ids[1],
            .ebo = ids[2],
            .vertex_count = 0,
            .index_count = 0,
            .allocator = allocator,
        };
    }

    pub fn upload(self: *Mesh, vertices: []const u32, indices: []const u32) void {
        self.vertex_count = @intCast(vertices.len);
        self.index_count  = @intCast(indices.len);

        gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo);
        gl.bufferData(gl.ARRAY_BUFFER,
            @intCast(vertices.len * @sizeOf(u32)),
            vertices.ptr, gl.DYNAMIC_DRAW);

        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.ebo);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER,
            @intCast(indices.len * @sizeOf(u32)),
            indices.ptr, gl.DYNAMIC_DRAW);
    }

    pub fn draw(self: *const Mesh) void {
        if (self.index_count == 0) return;
        gl.bindVertexArray(self.vao);
        gl.drawElements(gl.TRIANGLES, @intCast(self.index_count), gl.UNSIGNED_INT, 0);
        gl.bindVertexArray(0);
    }

    pub fn deinit(self: *Mesh) void {
        gl.deleteBuffers(1, &self.ebo);
        gl.deleteBuffers(1, &self.vbo);
        gl.deleteVertexArrays(1, &self.vao);
    }
};
