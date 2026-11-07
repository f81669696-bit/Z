const std = @import("std");

pub const Vec2 = struct {
    x: f32, y: f32,
    pub fn new(x: f32, y: f32) Vec2 { return .{ .x = x, .y = y }; }
    pub fn add(a: Vec2, b: Vec2) Vec2 { return .{ .x = a.x+b.x, .y = a.y+b.y }; }
    pub fn sub(a: Vec2, b: Vec2) Vec2 { return .{ .x = a.x-b.x, .y = a.y-b.y }; }
    pub fn scale(a: Vec2, s: f32) Vec2 { return .{ .x = a.x*s, .y = a.y*s }; }
    pub fn dot(a: Vec2, b: Vec2) f32 { return a.x*b.x + a.y*b.y; }
    pub fn len(a: Vec2) f32 { return std.math.sqrt(a.x*a.x + a.y*a.y); }
    pub fn norm(a: Vec2) Vec2 { const l = a.len(); if (l == 0) return .{.x=0,.y=0}; return a.scale(1.0/l); }
};

pub const Vec3 = struct {
    x: f32, y: f32, z: f32,
    pub fn new(x: f32, y: f32, z: f32) Vec3 { return .{ .x = x, .y = y, .z = z }; }
    pub fn add(a: Vec3, b: Vec3) Vec3 { return .{ .x = a.x+b.x, .y = a.y+b.y, .z = a.z+b.z }; }
    pub fn sub(a: Vec3, b: Vec3) Vec3 { return .{ .x = a.x-b.x, .y = a.y-b.y, .z = a.z-b.z }; }
    pub fn scale(a: Vec3, s: f32) Vec3 { return .{ .x = a.x*s, .y = a.y*s, .z = a.z*s }; }
    pub fn dot(a: Vec3, b: Vec3) f32 { return a.x*b.x + a.y*b.y + a.z*b.z; }
    pub fn cross(a: Vec3, b: Vec3) Vec3 { return .{ .x=a.y*b.z-a.z*b.y, .y=a.z*b.x-a.x*b.z, .z=a.x*b.y-a.y*b.x }; }
    pub fn len(a: Vec3) f32 { return std.math.sqrt(a.x*a.x + a.y*a.y + a.z*a.z); }
    pub fn norm(a: Vec3) Vec3 { const l = a.len(); if (l == 0) return .{.x=0,.y=0,.z=0}; return a.scale(1.0/l); }
};

pub const Vec4 = struct {
    x: f32, y: f32, z: f32, w: f32,
    pub fn new(x: f32, y: f32, z: f32, w: f32) Vec4 { return .{ .x = x, .y = y, .z = z, .w = w }; }
    pub fn add(a: Vec4, b: Vec4) Vec4 { return .{ .x = a.x+b.x, .y = a.y+b.y, .z = a.z+b.z, .w = a.w+b.w }; }
    pub fn scale(a: Vec4, s: f32) Vec4 { return .{ .x = a.x*s, .y = a.y*s, .z = a.z*s, .w = a.w*s }; }
    pub fn dot(a: Vec4, b: Vec4) f32 { return a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w; }
};