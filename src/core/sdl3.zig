const std = @import("std");

// SDL3 bindings — dynamic loading via dlopen/LoadLibrary
// SDL3 3.4.20 API

pub const Window   = opaque {};
pub const GLContext = opaque {};

pub const WindowFlags = u64;
pub const WINDOW_OPENGL: WindowFlags = 0x0000000000000002;
pub const WINDOW_RESIZABLE: WindowFlags = 0x0000000000000020;
pub const WINDOW_FULLSCREEN: WindowFlags = 0x0000000000000001;

pub const GLattr = enum(c_int) {
    context_major_version = 17,
    context_minor_version = 18,
    context_profile_mask  = 21,
    context_flags         = 19,
    doublebuffer          = 5,
    depth_size            = 6,
};

pub const GL_CONTEXT_PROFILE_CORE: c_int = 0x0001;
pub const GL_CONTEXT_DEBUG_FLAG:   c_int = 0x0001;

pub const EventType = enum(u32) {
    quit              = 0x100,
    key_down          = 0x300,
    key_up            = 0x301,
    mouse_motion      = 0x400,
    mouse_button_down = 0x401,
    mouse_button_up   = 0x402,
    _,
};

pub const Keysym = extern struct {
    scancode: u32,
    sym:      i32,
    mod:      u16,
    _pad:     u16,
};

pub const KeyboardEvent = extern struct {
    type:      u32,
    reserved:  u32,
    timestamp: u64,
    windowID:  u32,
    which:     u32,
    scancode:  u32,
    key:       i32,
    mod:       u16,
    raw:       u16,
    down:      bool,
    repeat:    bool,
    _pad:      [2]u8,
};

pub const MouseMotionEvent = extern struct {
    type:      u32,
    reserved:  u32,
    timestamp: u64,
    windowID:  u32,
    which:     u32,
    state:     u32,
    x:         f32,
    y:         f32,
    xrel:      f32,
    yrel:      f32,
};

pub const MouseButtonEvent = extern struct {
    type:      u32,
    reserved:  u32,
    timestamp: u64,
    windowID:  u32,
    which:     u32,
    button:    u8,
    down:      bool,
    clicks:    u8,
    _pad:      u8,
    x:         f32,
    y:         f32,
};

pub const QuitEvent = extern struct {
    type:      u32,
    reserved:  u32,
    timestamp: u64,
};

pub const Event = extern union {
    type:   u32,
    key:    KeyboardEvent,
    motion: MouseMotionEvent,
    button: MouseButtonEvent,
    quit:   QuitEvent,
    _pad:   [128]u8,
};

// SDL keycodes (subset)
pub const SDLK_w:      i32 = 119;
pub const SDLK_a:      i32 = 97;
pub const SDLK_s:      i32 = 115;
pub const SDLK_d:      i32 = 100;
pub const SDLK_SPACE:  i32 = 32;
pub const SDLK_ESCAPE: i32 = 27;
pub const SDLK_LSHIFT: i32 = 0x400000E1;
pub const SDLK_LCTRL:  i32 = 0x400000E0;
pub const SDLK_F1:     i32 = 0x4000003A;
pub const SDLK_F3:     i32 = 0x4000003C;

// Function pointer table
var lib: ?std.DynLib = null;

var _Init:                    ?*const fn(u32) callconv(.C) bool = null;
var _Quit:                    ?*const fn() callconv(.C) void = null;
var _CreateWindow:            ?*const fn([*:0]const u8, c_int, c_int, WindowFlags) callconv(.C) ?*Window = null;
var _DestroyWindow:           ?*const fn(*Window) callconv(.C) void = null;
var _GL_SetAttribute:         ?*const fn(c_int, c_int) callconv(.C) bool = null;
var _GL_CreateContext:        ?*const fn(*Window) callconv(.C) ?*GLContext = null;
var _GL_MakeCurrent:          ?*const fn(*Window, *GLContext) callconv(.C) bool = null;
var _GL_SwapWindow:           ?*const fn(*Window) callconv(.C) bool = null;
var _GL_SetSwapInterval:      ?*const fn(c_int) callconv(.C) bool = null;
var _GL_GetProcAddress:       ?*const fn([*:0]const u8) callconv(.C) ?*anyopaque = null;
var _GL_DestroyContext:       ?*const fn(*GLContext) callconv(.C) void = null;
var _PollEvent:               ?*const fn(*Event) callconv(.C) bool = null;
var _GetWindowSize:           ?*const fn(*Window, *c_int, *c_int) callconv(.C) bool = null;
var _SetWindowRelativeMouseMode: ?*const fn(*Window, bool) callconv(.C) bool = null;
var _GetError:                ?*const fn() callconv(.C) [*:0]const u8 = null;

pub fn load() !void {
    // try common SDL3 lib names on Linux
    const names = [_][]const u8{
        "libSDL3.so.0", "libSDL3.so", "SDL3.dll",
    };
    for (names) |name| {
        if (std.DynLib.open(name)) |l| {
            lib = l;
            break;
        } else |_| {}
    }
    if (lib == null) return error.SDL3NotFound;
    var l = &lib.?;

    _Init                    = @ptrCast(l.lookup(*anyopaque, "SDL_Init"));
    _Quit                    = @ptrCast(l.lookup(*anyopaque, "SDL_Quit"));
    _CreateWindow            = @ptrCast(l.lookup(*anyopaque, "SDL_CreateWindow"));
    _DestroyWindow           = @ptrCast(l.lookup(*anyopaque, "SDL_DestroyWindow"));
    _GL_SetAttribute         = @ptrCast(l.lookup(*anyopaque, "SDL_GL_SetAttribute"));
    _GL_CreateContext        = @ptrCast(l.lookup(*anyopaque, "SDL_GL_CreateContext"));
    _GL_MakeCurrent          = @ptrCast(l.lookup(*anyopaque, "SDL_GL_MakeCurrent"));
    _GL_SwapWindow           = @ptrCast(l.lookup(*anyopaque, "SDL_GL_SwapWindow"));
    _GL_SetSwapInterval      = @ptrCast(l.lookup(*anyopaque, "SDL_GL_SetSwapInterval"));
    _GL_GetProcAddress       = @ptrCast(l.lookup(*anyopaque, "SDL_GL_GetProcAddress"));
    _GL_DestroyContext       = @ptrCast(l.lookup(*anyopaque, "SDL_GL_DestroyContext"));
    _PollEvent               = @ptrCast(l.lookup(*anyopaque, "SDL_PollEvent"));
    _GetWindowSize           = @ptrCast(l.lookup(*anyopaque, "SDL_GetWindowSize"));
    _SetWindowRelativeMouseMode = @ptrCast(l.lookup(*anyopaque, "SDL_SetWindowRelativeMouseMode"));
    _GetError                = @ptrCast(l.lookup(*anyopaque, "SDL_GetError"));
}

pub fn unload() void {
    if (lib) |*l| l.close();
    lib = null;
}

pub fn init(flags: u32) bool { return _Init.?(flags); }
pub fn quit() void { _Quit.?(); }
pub fn createWindow(title: [*:0]const u8, w: c_int, h: c_int, flags: WindowFlags) ?*Window { return _CreateWindow.?(title, w, h, flags); }
pub fn destroyWindow(win: *Window) void { _DestroyWindow.?(win); }
pub fn glSetAttribute(attr: c_int, val: c_int) bool { return _GL_SetAttribute.?(attr, val); }
pub fn glCreateContext(win: *Window) ?*GLContext { return _GL_CreateContext.?(win); }
pub fn glMakeCurrent(win: *Window, ctx: *GLContext) bool { return _GL_MakeCurrent.?(win, ctx); }
pub fn glSwapWindow(win: *Window) bool { return _GL_SwapWindow.?(win); }
pub fn glSetSwapInterval(interval: c_int) bool { return _GL_SetSwapInterval.?(interval); }
pub fn glGetProcAddress(name: [*:0]const u8) ?*anyopaque { return _GL_GetProcAddress.?(name); }
pub fn glDestroyContext(ctx: *GLContext) void { _GL_DestroyContext.?(ctx); }
pub fn pollEvent(event: *Event) bool { return _PollEvent.?(event); }
pub fn getWindowSize(win: *Window, w: *c_int, h: *c_int) bool { return _GetWindowSize.?(win, w, h); }
pub fn setWindowRelativeMouseMode(win: *Window, enabled: bool) bool { return _SetWindowRelativeMouseMode.?(win, enabled); }
pub fn getError() [*:0]const u8 { return _GetError.?(); }
