const std = @import("std");
const gl = @import("gl.zig");

pub const Shader = struct {
    id: gl.GLuint,

    pub fn init(vert_src: []const u8, frag_src: []const u8) !Shader {
        const vert = try compileShader(gl.VERTEX_SHADER, vert_src);
        defer gl.deleteShader(vert);
        const frag = try compileShader(gl.FRAGMENT_SHADER, frag_src);
        defer gl.deleteShader(frag);

        const prog = gl.createProgram();
        gl.attachShader(prog, vert);
        gl.attachShader(prog, frag);
        gl.linkProgram(prog);

        var status: gl.GLint = 0;
        gl.getProgramiv(prog, gl.LINK_STATUS, @ptrCast(&status));
        if (status == 0) return error.ShaderLinkFailed;

        return .{ .id = prog };
    }

    pub fn bind(self: *const Shader) void {
        gl.useProgram(self.id);
    }

    pub fn setMat4(self: *const Shader, name: [*:0]const u8, m: [16]f32) void {
        const loc = gl.getUniformLocation(self.id, name);
        gl.uniformMatrix4fv(loc, 1, gl.FALSE, &m);
    }

    pub fn setInt(self: *const Shader, name: [*:0]const u8, v: i32) void {
        const loc = gl.getUniformLocation(self.id, name);
        gl.uniform1i(loc, v);
    }

    pub fn setFloat(self: *const Shader, name: [*:0]const u8, v: f32) void {
        const loc = gl.getUniformLocation(self.id, name);
        gl.uniform1f(loc, v);
    }
};

fn compileShader(typ: gl.GLenum, src: []const u8) !gl.GLuint {
    const shader = gl.createShader(typ);
    const ptr: [*]const u8 = src.ptr;
    const len: gl.GLint = @intCast(src.len);
    gl.shaderSource(shader, 1, @ptrCast(&ptr), &len);
    gl.compileShader(shader);

    var status: gl.GLint = 0;
    gl.getShaderiv(shader, gl.COMPILE_STATUS, @ptrCast(&status));
    if (status == 0) {
        var log_buf: [512]u8 = undefined;
        gl.getShaderInfoLog(shader, 512, null, &log_buf);
        const stderr = std.io.getStdErr().writer();
        stderr.print("shader error: {s}\n", .{log_buf}) catch {};
        return error.ShaderCompileFailed;
    }
    return shader;
}

pub const CHUNK_VERT =
    \\#version 330 core
    \\layout(location=0) in uint packed;
    \\uniform mat4 u_mvp;
    \\uniform int  u_chunk_x;
    \\uniform int  u_chunk_z;
    \\out vec2 v_uv;
    \\flat out uint v_tex;
    \\out float v_light;
    \\void main() {
    \\    uint x  = (packed      ) & 0x1Fu;
    \\    uint y  = (packed >>  5) & 0xFFu;
    \\    uint z  = (packed >> 13) & 0x1Fu;
    \\    uint u  = (packed >> 18) & 0x1u;
    \\    uint v  = (packed >> 19) & 0x1u;
    \\    uint tx = (packed >> 20) & 0xFFu;
    \\    uint li = (packed >> 28) & 0xFu;
    \\    vec3 pos = vec3(float(u_chunk_x*16) + float(x),
    \\                   float(y),
    \\                   float(u_chunk_z*16) + float(z));
    \\    gl_Position = u_mvp * vec4(pos, 1.0);
    \\    v_uv    = vec2(float(u), float(v));
    \\    v_tex   = tx;
    \\    v_light = float(li) / 15.0;
    \\}
;

pub const CHUNK_FRAG =
    \\#version 330 core
    \\in vec2 v_uv;
    \\flat in uint v_tex;
    \\in float v_light;
    \\uniform sampler2DArray u_atlas;
    \\out vec4 frag_color;
    \\void main() {
    \\    vec4 col = texture(u_atlas, vec3(v_uv, float(v_tex)));
    \\    if (col.a < 0.1) discard;
    \\    frag_color = vec4(col.rgb * v_light, col.a);
    \\}
;
