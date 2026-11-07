const std = @import("std");
const sdl = @import("sdl3.zig");
const gl  = @import("../renderer/gl.zig");

pub const WindowConfig = struct {
    title:      []const u8 = "Cube",
    width:      u32 = 854,
    height:     u32 = 480,
    fullscreen: bool = false,
    vsync:      bool = true,
};

pub const Window = struct {
    config:  WindowConfig,
    handle:  *sdl.Window,
    gl_ctx:  *sdl.GLContext,
    running: bool,

    pub fn init(config: WindowConfig) !Window {
        try sdl.load();
        if (!sdl.init(0x00000020)) // SDL_INIT_VIDEO
            return error.SDLInitFailed;

        // OpenGL 3.3 Core
        _ = sdl.glSetAttribute(@intFromEnum(sdl.GLattr.context_major_version), 3);
        _ = sdl.glSetAttribute(@intFromEnum(sdl.GLattr.context_minor_version), 3);
        _ = sdl.glSetAttribute(@intFromEnum(sdl.GLattr.context_profile_mask), sdl.GL_CONTEXT_PROFILE_CORE);
        _ = sdl.glSetAttribute(@intFromEnum(sdl.GLattr.doublebuffer), 1);
        _ = sdl.glSetAttribute(@intFromEnum(sdl.GLattr.depth_size), 24);

        var flags: sdl.WindowFlags = sdl.WINDOW_OPENGL | sdl.WINDOW_RESIZABLE;
        if (config.fullscreen) flags |= sdl.WINDOW_FULLSCREEN;

        const title_z = try std.fmt.allocPrintZ(std.heap.page_allocator, "{s}", .{config.title});
        defer std.heap.page_allocator.free(title_z);

        const handle = sdl.createWindow(title_z, @intCast(config.width), @intCast(config.height), flags)
            orelse return error.WindowCreateFailed;

        const ctx = sdl.glCreateContext(handle)
            orelse return error.GLContextFailed;

        _ = sdl.glMakeCurrent(handle, ctx);
        _ = sdl.glSetSwapInterval(if (config.vsync) 1 else 0);

        // load OpenGL functions
        gl.init(&sdlGetProc);

        // initial GL state
        gl.enable(gl.DEPTH_TEST);
        gl.depthFunc(gl.LEQUAL);
        gl.enable(gl.CULL_FACE);
        gl.cullFace(gl.BACK);
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
        gl.viewport(0, 0, @intCast(config.width), @intCast(config.height));

        return .{
            .config  = config,
            .handle  = handle,
            .gl_ctx  = @ptrCast(ctx),
            .running = true,
        };
    }

    pub fn deinit(self: *Window) void {
        sdl.glDestroyContext(@ptrCast(self.gl_ctx));
        sdl.destroyWindow(self.handle);
        sdl.quit();
        sdl.unload();
    }

    fn sdlGetProc(name: [*:0]const u8) callconv(.C) ?*anyopaque {
        return sdl.glGetProcAddress(name);
    }

    pub fn swap(self: *Window) void {
        _ = sdl.glSwapWindow(self.handle);
    }

    pub fn shouldClose(self: *const Window) bool { return !self.running; }
    pub fn close(self: *Window) void { self.running = false; }

    pub fn getWidth(self: *const Window) u32 { return self.config.width; }
    pub fn getHeight(self: *const Window) u32 { return self.config.height; }
    pub fn getAspect(self: *const Window) f32 {
        return @as(f32, @floatFromInt(self.config.width)) /
               @as(f32, @floatFromInt(self.config.height));
    }

    pub fn clearColor(r: f32, g: f32, b: f32) void {
        gl.clearColor(r, g, b, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    }
};
