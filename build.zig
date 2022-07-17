const std = @import("std");

const pkgs = struct {
    const zuri = std.build.Pkg{
        .name = "zuri",
        .path = . { .path = "./deps/zuri/src/zuri.zig" },
    };
};

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();

    const static = b.addStaticLibrary("zuri", "src/zuri.zig");
    static.setBuildMode(mode);
    static.addPackage(pkgs.zuri);
    static.linkLibC();
    static.install();

    const shared = b.addSharedLibrary("zuri", "src/zuri.zig", .unversioned);
    shared.setBuildMode(mode);
    shared.addPackage(pkgs.zuri);
    shared.linkLibC();
    shared.install();
}
