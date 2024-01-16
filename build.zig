const std = @import("std");

const targets = struct {
    const riscv = .{
        .cpu_arch = .riscv32,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.generic_rv32 },
        .cpu_features_add = std.Target.riscv.featureSet(&.{
            std.Target.riscv.Feature.c,
            std.Target.riscv.Feature.m,
        }),
        .os_tag = .freestanding,
        .abi = .eabi,
    };
};

pub fn build(b: *std.Build) void {
    const espnow: bool = b.option(bool, "espnow", "espnow") orelse false;
    const mesh: bool = b.option(bool, "mesh", "mesh") orelse false;
    const dep = b.dependency("esp32-wifi-lib", .{});

    const lib = b.addStaticLibrary(.{
        .name = "esp32c3",
        .target = b.resolveTargetQuery(targets.riscv),
        .optimize = .ReleaseSafe,
    });

    lib.addObjectFile(dep.path("esp32c3/libcore.a"));
    lib.addObjectFile(dep.path("esp32c3/libnet80211.a"));
    lib.addObjectFile(dep.path("esp32c3/libpp.a"));
    lib.addObjectFile(dep.path("esp32c3/libsmartconfig.a"));
    lib.addObjectFile(dep.path("esp32c3/libwapi.a"));

    if (espnow)
        lib.addObjectFile(dep.path("esp32c3/libespnow.a"));

    if (mesh)
        lib.addObjectFile(dep.path("esp32c3/libmesh.a"));

    b.installArtifact(lib);
}
