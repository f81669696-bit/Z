const std = @import("std");
const Vec3 = @import("vec.zig").Vec3;
const Vec4 = @import("vec.zig").Vec4;

pub const Mat4 = struct {
    m: [16]f32,

    pub fn identity() Mat4 {
        return .{ .m = .{
            1,0,0,0,
            0,1,0,0,
            0,0,1,0,
            0,0,0,1,
        }};
    }

    pub fn mul(a: Mat4, b: Mat4) Mat4 {
        var r = Mat4{ .m = [_]f32{0} ** 16 };
        var i: usize = 0;
        while (i < 4) : (i += 1) {
            var j: usize = 0;
            while (j < 4) : (j += 1) {
                var k: usize = 0;
                while (k < 4) : (k += 1) {
                    r.m[i*4+j] += a.m[i*4+k] * b.m[k*4+j];
                }
            }
        }
        return r;
    }

    pub fn perspective(fovy: f32, aspect: f32, near: f32, far: f32) Mat4 {
        const f = 1.0 / std.math.tan(fovy * 0.5);
        const nf = 1.0 / (near - far);
        return .{ .m = .{
            f/aspect, 0, 0,                    0,
            0,         f, 0,                    0,
            0,         0, (far+near)*nf,        -1,
            0,         0, 2.0*far*near*nf,       0,
        }};
    }

    pub fn lookAt(eye: Vec3, center: Vec3, up: Vec3) Mat4 {
        const f = center.sub(eye).norm();
        const s = f.cross(up).norm();
        const u = s.cross(f);
        return .{ .m = .{
            s.x,            u.x,            -f.x,           0,
            s.y,            u.y,            -f.y,           0,
            s.z,            u.z,            -f.z,           0,
            -s.dot(eye),    -u.dot(eye),    f.dot(eye),     1,
        }};
    }

    pub fn translate(v: Vec3) Mat4 {
        return .{ .m = .{
            1,   0,   0,   0,
            0,   1,   0,   0,
            0,   0,   1,   0,
            v.x, v.y, v.z, 1,
        }};
    }

    pub fn scale(v: Vec3) Mat4 {
        return .{ .m = .{
            v.x, 0,   0,   0,
            0,   v.y, 0,   0,
            0,   0,   v.z, 0,
            0,   0,   0,   1,
        }};
    }
};