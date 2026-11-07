const std = @import("std");
const log = @import("core/log.zig");
const Timer = @import("core/timer.zig").Timer;
const Window = @import("core/window.zig").Window;
const WindowConfig = @import("core/window.zig").WindowConfig;
const Input = @import("core/input.zig").Input;
const World = @import("world/world.zig").World;
const Player = @import("entity/player.zig").Player;
const Vec3 = @import("math/vec.zig").Vec3;
const Launcher = @import("launcher/launcher.zig").Launcher;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.setLevel(.info);
    log.info("Cube v{s} starting", .{@import("launcher/updater.zig").Updater.CURRENT_VERSION});

    // launcher
    var launcher = Launcher.init(allocator);
    defer launcher.deinit();
    try launcher.loginOffline("Player");
    log.info("logged in as: {s}", .{launcher.profile.getUsername()});

    // window
    var window = Window.init(WindowConfig{
        .title = "Cube",
        .width = 854,
        .height = 480,
    });

    // world
    var world = World.init(allocator, 12345, 8);
    defer world.deinit();

    // player
    var player = Player.init(Vec3.new(0, 80, 0));

    // input
    var input = Input.init();

    // timer
    var timer = Timer.init();

    // load initial chunks
    try world.updateChunksAround(player.pos);
    log.info("initial chunks loaded", .{});

    // main loop
    while (!window.shouldClose()) {
        timer.tick();
        input.beginFrame();

        // process input
        if (input.isPressed(.escape)) window.close();

        player.processInput(&input, timer.getDelta());

        // load chunks around player
        try world.updateChunksAround(player.pos);

        // log fps every 5 seconds
        if (@mod(timer.total, 5.0) < timer.getDelta()) {
            log.info("FPS: {d:.1} pos: {d:.1},{d:.1},{d:.1}",
                .{ timer.getFps(), player.pos.x, player.pos.y, player.pos.z });
        }
    }

    log.info("shutting down", .{});
}