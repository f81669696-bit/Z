const std = @import("std");

pub const WindowConfig = struct {
    title: []const u8 = "Cube",
    width: u32 = 854,
    height: u32 = 480,
    fullscreen: bool = false,
    vsync: bool = true,
};

pub const Window = struct {
    config: WindowConfig,
    running: bool,

    pub fn init(config: WindowConfig) Window {
        return .{
            .config = config,
            .running = true,
        };
    }

    pub fn shouldClose(self: *Window) bool {
        return !self.running;
    }

    pub fn close(self: *Window) void {
        self.running = false;
    }

    pub fn getWidth(self: *const Window) u32 {
        return self.config.width;
    }

    pub fn getHeight(self: *const Window) u32 {
        return self.config.height;
    }

    pub fn getAspect(self: *const Window) f32 {
        return @as(f32, @floatFromInt(self.config.width)) /
               @as(f32, @floatFromInt(self.config.height));
    }
};