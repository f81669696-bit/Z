const std = @import("std");

pub const Key = enum(u32) {
    w = 0, a, s, d,
    space, shift, ctrl,
    escape, f1, f2, f3,
    up, down, left, right,
    count,
};

pub const MouseButton = enum(u8) {
    left = 0, right, middle, count,
};

pub const Input = struct {
    keys: [@intFromEnum(Key.count)]bool = [_]bool{false} ** @intFromEnum(Key.count),
    keys_prev: [@intFromEnum(Key.count)]bool = [_]bool{false} ** @intFromEnum(Key.count),
    mouse_x: f32 = 0,
    mouse_y: f32 = 0,
    mouse_dx: f32 = 0,
    mouse_dy: f32 = 0,
    buttons: [@intFromEnum(MouseButton.count)]bool = [_]bool{false} ** @intFromEnum(MouseButton.count),

    pub fn init() Input {
        return .{};
    }

    pub fn beginFrame(self: *Input) void {
        self.keys_prev = self.keys;
        self.mouse_dx = 0;
        self.mouse_dy = 0;
    }

    pub fn setKey(self: *Input, key: Key, pressed: bool) void {
        self.keys[@intFromEnum(key)] = pressed;
    }

    pub fn isDown(self: *const Input, key: Key) bool {
        return self.keys[@intFromEnum(key)];
    }

    pub fn isPressed(self: *const Input, key: Key) bool {
        return self.keys[@intFromEnum(key)] and !self.keys_prev[@intFromEnum(key)];
    }

    pub fn isReleased(self: *const Input, key: Key) bool {
        return !self.keys[@intFromEnum(key)] and self.keys_prev[@intFromEnum(key)];
    }

    pub fn setMousePos(self: *Input, x: f32, y: f32) void {
        self.mouse_dx = x - self.mouse_x;
        self.mouse_dy = y - self.mouse_y;
        self.mouse_x = x;
        self.mouse_y = y;
    }

    pub fn setMouseButton(self: *Input, btn: MouseButton, pressed: bool) void {
        self.buttons[@intFromEnum(btn)] = pressed;
    }

    pub fn isMouseDown(self: *const Input, btn: MouseButton) bool {
        return self.buttons[@intFromEnum(btn)];
    }
};