const std = @import("std");
const log     = @import("core/log.zig");
const Timer   = @import("core/timer.zig").Timer;
const Window  = @import("core/window.zig").Window;
const WindowConfig = @import("core/window.zig").WindowConfig;
const Input   = @import("core/input.zig").Input;
const sdl     = @import("core/sdl3.zig");
const World   = @import("world/world.zig").World;
const Player  = @import("entity/player.zig").Player;
const Vec3    = @import("math/vec.zig").Vec3;
const Launcher = @import("launcher/launcher.zig").Launcher;
const ChunkRenderer = @import("renderer/chunk_renderer.zig").ChunkRenderer;
const LightMap = @import("world/light.zig").LightMap;
const light_mod = @import("world/light.zig");
const gl      = @import("renderer/gl.zig");
const Shader  = @import("renderer/shader.zig").Shader;
const shader_src = @import("renderer/shader.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.setLevel(.info);
    log.info("Cube v{s} starting", .{@import("launcher/updater.zig").Updater.CURRENT_VERSION});

    // launcher / auth
    var launcher = Launcher.init(allocator);
    defer launcher.deinit();
    try launcher.loginOffline("Player");
    log.info("logged in as: {s}", .{launcher.profile.getUsername()});

    // window + GL
    var window = try Window.init(WindowConfig{
        .title  = "Cube",
        .width  = 854,
        .height = 480,
        .vsync  = true,
    });
    defer window.deinit();

    // capture mouse
    _ = sdl.setWindowRelativeMouseMode(window.handle, true);

    // shader
    var chunk_shader = try Shader.init(shader_src.CHUNK_VERT, shader_src.CHUNK_FRAG);

    // world
    var world = World.init(allocator, 12345, 6);
    defer world.deinit();

    // player
    var player = Player.init(Vec3.new(0, 90, 0));

    // input / timer
    var input = Input.init();
    var timer = Timer.init();

    // load initial chunks
    try world.updateChunksAround(player.pos);

    // build chunk renderers
    var renderers = std.AutoHashMap(u64, ChunkRenderer).init(allocator);
    defer {
        var it = renderers.valueIterator();
        while (it.next()) |r| r.deinit();
        renderers.deinit();
    }

    log.info("entering main loop", .{});

    while (!window.shouldClose() and !input.quit) {
        timer.tick();
        input.beginFrame();

        // poll SDL events
        var ev: sdl.Event = undefined;
        while (sdl.pollEvent(&ev)) {
            input.processEvent(&ev);
        }

        if (input.isPressed(.escape)) window.close();

        player.processInput(&input, timer.getDelta());
        try world.updateChunksAround(player.pos);

        // rebuild dirty chunk meshes
        {
            var it = world.chunks.iterator();
            while (it.next()) |entry| {
                const chunk = entry.value_ptr.*;
                if (!chunk.dirty) continue;

                var lm = LightMap.init();
                light_mod.propagateSkyLight(chunk, &lm);
                light_mod.propagateBlockLight(chunk, &lm);

                const key = entry.key_ptr.*;
                if (!renderers.contains(key)) {
                    const cr = try ChunkRenderer.init(allocator);
                    try renderers.put(key, cr);
                }
                const cr = renderers.getPtr(key).?;
                try cr.rebuild(chunk, &lm);
                chunk.dirty = false;
            }
        }

        // render
        Window.clearColor(0.53, 0.81, 0.98); // sky blue

        chunk_shader.bind();

        // view/proj matrices
        const aspect = window.getAspect();
        const proj = @import("math/mat.zig").Mat4.perspective(
            std.math.degreesToRadians(70.0), aspect, 0.05, 1000.0);
        const eye   = player.getEyePos();
        const look  = eye.add(player.getLookDir());
        const up    = Vec3.new(0, 1, 0);
        const view  = @import("math/mat.zig").Mat4.lookAt(eye, look, up);
        const mvp   = proj.mul(view);

        chunk_shader.setMat4("u_mvp", mvp.m);
        chunk_shader.setInt("u_atlas", 0);

        // draw chunks
        {
            var it = world.chunks.iterator();
            while (it.next()) |entry| {
                const chunk = entry.value_ptr.*;
                chunk_shader.setInt("u_chunk_x", chunk.pos.x);
                chunk_shader.setInt("u_chunk_z", chunk.pos.z);
                if (renderers.getPtr(entry.key_ptr.*)) |cr| cr.draw();
            }
        }

        window.swap();

        if (@mod(timer.total, 5.0) < timer.getDelta()) {
            log.info("FPS:{d:.0} pos:{d:.1},{d:.1},{d:.1}",
                .{ timer.getFps(), player.pos.x, player.pos.y, player.pos.z });
        }
    }

    log.info("shutdown", .{});
}
