const std = @import("std");
const Vec3 = @import("../math/vec.zig").Vec3;
const AABB = @import("../math/aabb.zig").AABB;
const Input = @import("../core/input.zig").Input;
const Key = @import("../core/input.zig").Key;

pub const PLAYER_WIDTH:  f32 = 0.6;
pub const PLAYER_HEIGHT: f32 = 1.8;
pub const PLAYER_EYE:    f32 = 1.62;
pub const WALK_SPEED:    f32 = 4.317;
pub const SPRINT_SPEED:  f32 = 5.612;
pub const SNEAK_SPEED:   f32 = 1.295;
pub const JUMP_VEL:      f32 = 8.0;
pub const GRAVITY:       f32 = 32.0;
pub const TERMINAL_VEL:  f32 = 78.4;

pub const Player = struct {
    pos: Vec3,
    vel: Vec3,
    yaw: f32,
    pitch: f32,
    on_ground: bool,
    sprinting: bool,
    sneaking: bool,
    health: f32,
    food: f32,

    pub fn init(spawn: Vec3) Player {
        return .{
            .pos = spawn,
            .vel = Vec3.new(0, 0, 0),
            .yaw = 0,
            .pitch = 0,
            .on_ground = false,
            .sprinting = false,
            .sneaking = false,
            .health = 20,
            .food = 20,
        };
    }

    pub fn getEyePos(self: *const Player) Vec3 {
        return Vec3.new(self.pos.x, self.pos.y + PLAYER_EYE, self.pos.z);
    }

    pub fn getAABB(self: *const Player) AABB {
        const hw = PLAYER_WIDTH * 0.5;
        return AABB.new(
            Vec3.new(self.pos.x - hw, self.pos.y, self.pos.z - hw),
            Vec3.new(self.pos.x + hw, self.pos.y + PLAYER_HEIGHT, self.pos.z + hw),
        );
    }

    pub fn getLookDir(self: *const Player) Vec3 {
        const cy = @cos(self.yaw);
        const sy = @sin(self.yaw);
        const cp = @cos(self.pitch);
        const sp = @sin(self.pitch);
        return Vec3.new(cy * cp, sp, sy * cp).norm();
    }

    pub fn processInput(self: *Player, input: *const Input, dt: f32) void {
        self.sprinting = input.isDown(.ctrl);
        self.sneaking  = input.isDown(.shift);

        const speed = if (self.sprinting) SPRINT_SPEED
                      else if (self.sneaking) SNEAK_SPEED
                      else WALK_SPEED;

        const cy = @cos(self.yaw);
        const sy = @sin(self.yaw);
        var move = Vec3.new(0, 0, 0);

        if (input.isDown(.w)) move = move.add(Vec3.new(cy, 0, sy));
        if (input.isDown(.s)) move = move.add(Vec3.new(-cy, 0, -sy));
        if (input.isDown(.a)) move = move.add(Vec3.new(-sy, 0, cy));
        if (input.isDown(.d)) move = move.add(Vec3.new(sy, 0, -cy));

        if (move.len() > 0) move = move.norm().scale(speed);

        self.vel.x = move.x;
        self.vel.z = move.z;

        if (input.isPressed(.space) and self.on_ground) {
            self.vel.y = JUMP_VEL;
            self.on_ground = false;
        }

        // mouse look
        const sens: f32 = 0.002;
        self.yaw   += input.mouse_dx * sens;
        self.pitch -= input.mouse_dy * sens;
        const max_pitch = std.math.pi * 0.499;
        self.pitch = std.math.clamp(self.pitch, -max_pitch, max_pitch);

        // gravity
        if (!self.on_ground) {
            self.vel.y -= GRAVITY * dt;
            if (self.vel.y < -TERMINAL_VEL) self.vel.y = -TERMINAL_VEL;
        }

        // apply — collision resolved outside
        self.pos = self.pos.add(self.vel.scale(dt));
        _ = dt;
    }
};