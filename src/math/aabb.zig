const Vec3 = @import("vec.zig").Vec3;

pub const AABB = struct {
    min: Vec3,
    max: Vec3,

    pub fn new(min: Vec3, max: Vec3) AABB {
        return .{ .min = min, .max = max };
    }

    pub fn fromCenter(center: Vec3, half: Vec3) AABB {
        return .{
            .min = center.sub(half),
            .max = center.add(half),
        };
    }

    pub fn intersects(a: AABB, b: AABB) bool {
        return a.min.x <= b.max.x and a.max.x >= b.min.x and
               a.min.y <= b.max.y and a.max.y >= b.min.y and
               a.min.z <= b.max.z and a.max.z >= b.min.z;
    }

    pub fn contains(self: AABB, p: Vec3) bool {
        return p.x >= self.min.x and p.x <= self.max.x and
               p.y >= self.min.y and p.y <= self.max.y and
               p.z >= self.min.z and p.z <= self.max.z;
    }

    pub fn center(self: AABB) Vec3 {
        return self.min.add(self.max).scale(0.5);
    }

    pub fn size(self: AABB) Vec3 {
        return self.max.sub(self.min);
    }

    pub fn expand(self: AABB, v: Vec3) AABB {
        return .{
            .min = Vec3.new(
                @min(self.min.x, self.min.x + v.x),
                @min(self.min.y, self.min.y + v.y),
                @min(self.min.z, self.min.z + v.z),
            ),
            .max = Vec3.new(
                @max(self.max.x, self.max.x + v.x),
                @max(self.max.y, self.max.y + v.y),
                @max(self.max.z, self.max.z + v.z),
            ),
        };
    }
};