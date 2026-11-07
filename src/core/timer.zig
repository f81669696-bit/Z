const std = @import("std");

pub const Timer = struct {
    start_ns: u64,
    last_ns: u64,
    delta: f32,
    total: f64,
    fps: f32,
    frame_count: u64,
    fps_timer: f32,
    fps_frames: u32,

    pub fn init() Timer {
        const now = @as(u64, @intCast(std.time.nanoTimestamp()));
        return .{
            .start_ns = now,
            .last_ns = now,
            .delta = 0.0,
            .total = 0.0,
            .fps = 0.0,
            .frame_count = 0,
            .fps_timer = 0.0,
            .fps_frames = 0,
        };
    }

    pub fn tick(self: *Timer) void {
        const now = @as(u64, @intCast(std.time.nanoTimestamp()));
        const diff = now - self.last_ns;
        self.delta = @as(f32, @floatFromInt(diff)) / 1_000_000_000.0;
        // cap delta to 100ms to avoid spiral of death
        if (self.delta > 0.1) self.delta = 0.1;
        self.total += self.delta;
        self.last_ns = now;
        self.frame_count += 1;
        self.fps_timer += self.delta;
        self.fps_frames += 1;
        if (self.fps_timer >= 1.0) {
            self.fps = @as(f32, @floatFromInt(self.fps_frames)) / self.fps_timer;
            self.fps_timer = 0.0;
            self.fps_frames = 0;
        }
    }

    pub fn getDelta(self: *const Timer) f32 {
        return self.delta;
    }

    pub fn getFps(self: *const Timer) f32 {
        return self.fps;
    }
};