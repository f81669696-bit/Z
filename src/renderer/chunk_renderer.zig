const std = @import("std");
const Mesh = @import("mesh.zig").Mesh;
const packVertex = @import("mesh.zig").packVertex;
const Chunk = @import("../world/chunk.zig").Chunk;
const CHUNK_W = @import("../world/chunk.zig").CHUNK_W;
const CHUNK_H = @import("../world/chunk.zig").CHUNK_H;
const CHUNK_D = @import("../world/chunk.zig").CHUNK_D;
const block = @import("../world/block.zig");
const LightMap = @import("../world/light.zig").LightMap;

// Face directions
const Face = enum(u8) { top=0, bottom, north, south, east, west };

// Face normals and vertex offsets
const FACE_VERTS = [6][4][3]u8{
    // top (y+1)
    .{.{0,1,0},.{1,1,0},.{1,1,1},.{0,1,1}},
    // bottom (y)
    .{.{0,0,1},.{1,0,1},.{1,0,0},.{0,0,0}},
    // north (z)
    .{.{0,1,0},.{0,0,0},.{1,0,0},.{1,1,0}},
    // south (z+1)
    .{.{1,1,1},.{1,0,1},.{0,0,1},.{0,1,1}},
    // east (x+1)
    .{.{1,1,0},.{1,0,0},.{1,0,1},.{1,1,1}},
    // west (x)
    .{.{0,1,1},.{0,0,1},.{0,0,0},.{0,1,0}},
};

const FACE_UVS = [4][2]u1{
    .{0,0},.{0,1},.{1,1},.{1,0},
};

const FACE_NORMALS = [6][3]i8{
    .{0,1,0}, .{0,-1,0}, .{0,0,-1},
    .{0,0,1}, .{1,0,0},  .{-1,0,0},
};

pub const ChunkRenderer = struct {
    mesh: Mesh,
    verts: std.ArrayList(u32),
    idxs:  std.ArrayList(u32),

    pub fn init(allocator: std.mem.Allocator) !ChunkRenderer {
        return .{
            .mesh  = try Mesh.init(allocator),
            .verts = std.ArrayList(u32).init(allocator),
            .idxs  = std.ArrayList(u32).init(allocator),
        };
    }

    pub fn deinit(self: *ChunkRenderer) void {
        self.mesh.deinit();
        self.verts.deinit();
        self.idxs.deinit();
    }

    pub fn rebuild(self: *ChunkRenderer, chunk: *const Chunk, light: *const LightMap) !void {
        self.verts.clearRetainingCapacity();
        self.idxs.clearRetainingCapacity();

        var x: i32 = 0;
        while (x < CHUNK_W) : (x += 1) {
            var y: i32 = 0;
            while (y < CHUNK_H) : (y += 1) {
                var z: i32 = 0;
                while (z < CHUNK_D) : (z += 1) {
                    const bid = chunk.get(x, y, z);
                    if (bid == block.AIR) continue;
                    if (block.isLiquid(bid)) continue; // liquid pass later

                    const def = block.getDef(bid);
                    const faces = [6]struct{ nx: i32, ny: i32, nz: i32, face: Face }{
                        .{.nx=0,.ny=1,.nz=0,.face=.top},
                        .{.nx=0,.ny=-1,.nz=0,.face=.bottom},
                        .{.nx=0,.ny=0,.nz=-1,.face=.north},
                        .{.nx=0,.ny=0,.nz=1,.face=.south},
                        .{.nx=1,.ny=0,.nz=0,.face=.east},
                        .{.nx=-1,.ny=0,.nz=0,.face=.west},
                    };

                    for (faces) |f| {
                        const nx = x + f.nx;
                        const ny = y + f.ny;
                        const nz = z + f.nz;
                        const nbid = chunk.get(nx, ny, nz);
                        if (block.isSolid(nbid) and !block.isTransparent(nbid)) continue;

                        const fi = @intFromEnum(f.face);
                        const tex = def.tex[fi];
                        const lv: u4 = if (ny >= 0 and ny < CHUNK_H and
                                           nx >= 0 and nx < CHUNK_W and
                                           nz >= 0 and nz < CHUNK_D)
                            light.getSky(nx, ny, nz)
                        else 15;

                        const base: u32 = @intCast(self.verts.items.len);
                        const fverts = FACE_VERTS[fi];
                        for (fverts, 0..) |fv, i| {
                            const vx: u5 = @intCast(@as(u32, @intCast(x)) + fv[0]);
                            const vy: u8 = @intCast(@as(u32, @intCast(y)) + fv[1]);
                            const vz: u5 = @intCast(@as(u32, @intCast(z)) + fv[2]);
                            const pu: u1 = FACE_UVS[i][0];
                            const pv: u1 = FACE_UVS[i][1];
                            try self.verts.append(packVertex(vx, vy, vz, pu, pv, @intCast(tex), lv));
                        }
                        // two triangles: 0,1,2  0,2,3
                        try self.idxs.appendSlice(&.{base,base+1,base+2, base,base+2,base+3});
                    }
                }
            }
        }
        self.mesh.upload(self.verts.items, self.idxs.items);
    }

    pub fn draw(self: *const ChunkRenderer) void {
        self.mesh.draw();
    }
};
