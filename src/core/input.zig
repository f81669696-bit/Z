const std = @import("std");
const sdl = @import("sdl3.zig");

pub const Key = enum(u32) {
    w = 0, a, s, d,
    space, shift, ctrl,
    escape, f1, f3,
    count,
};

pub const MouseButton = enum(u8) {
    left = 0, right, middle, count,
};

pub const Input = struct {
    keys:       [@intFromEnum(Key.count)]bool,
    keys_prev:  [@intFromEnum(Key.count)]bool,
    mouse_x:    f32,
    mouse_y:    f32,
    mouse_dx:   f32,
    mouse_dy:   f32,
    buttons:    [@intFromEnum(MouseButton.count)]bool,
    quit:       bool,

    pub fn init() Input {
        return .{
            .keys       = [_]bool{false} ** @intFromEnum(Key.count),
            .keys_prev  = [_]bool{false} ** @intFromEnum(Key.count),
            .mouse_x    = 0, .mouse_y = 0,
            .mouse_dx   = 0, .mouse_dy = 0,
            .buttons    = [_]bool{false} ** @intFromEnum(MouseButton.count),
            .quit       = false,
        };
    }

    pub fn beginFrame(self: *Input) void {
        self.keys_prev = self.keys;
        self.mouse_dx  = 0;
        self.mouse_dy  = 0;
    }

    pub fn processEvent(self: *Input, ev: *const sdl.Event) void {
        const etype: sdl.EventType = @enumFromInt(ev.type);
        switch (etype) {
            .quit => self.quit = true,
            .key_down, .key_up => {
                const pressed = etype == .key_down;
                const k = ev.key.key;
                if (k == sdl.SDLK_w)      self.keys[@intFromEnum(Key.w)]      = pressed;
                if (k == sdl.SDLK_a)      self.keys[@intFromEnum(Key.a)]      = pressed;
                if (k == sdl.SDLK_s)      self.keys[@intFromEnum(Key.s)]      = pressed;
                if (k == sdl.SDLK_d)      self.keys[@intFromEnum(Key.d)]      = pressed;
                if (k == sdl.SDLK_SPACE)  self.keys[@intFromEnum(Key.space)]  = pressed;
                if (k == sdl.SDLK_LSHIFT) self.keys[@intFromEnum(Key.shift)]  = pressed;
                if (k == sdl.SDLK_LCTRL)  self.keys[@intFromEnum(Key.ctrl)]   = pressed;
                if (k == sdl.SDLK_ESCAPE) self.keys[@intFromEnum(Key.escape)] = pressed;
                if (k == sdl.SDLK_F1)     self.keys[@intFromEnum(Key.f1)]     = pressed;
                if (k == sdl.SDLK_F3)     self.keys[@intFromEnum(Key.f3)]     = pressed;
            },
            .mouse_motion => {
                self.mouse_dx += ev.motion.xrel;
                self.mouse_dy += ev.motion.yrel;
                self.mouse_x   = ev.motion.x;
                self.mouse_y   = ev.motion.y;
            },
            .mouse_button_down, .mouse_button_up => {
                const pressed = etype == .mouse_button_down;
                switch (ev.button.button) {
                    1 => self.buttons[@intFromEnum(MouseButton.left)]   = pressed,
                    2 => self.buttons[@intFromEnum(MouseButton.middle)]  = pressed,
                    3 => self.buttons[@intFromEnum(MouseButton.right)]   = pressed,
                    else => {},
                }
            },
            else => {},
        }
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

    pub fn isMouseDown(self: *const Input, btn: MouseButton) bool {
        return self.buttons[@intFromEnum(btn)];
    }
};
