pub const days = .{
    @import("day01/day01.zig"),
    @import("day02/day02.zig"),
};

test "Everything" {
    @import("std").testing.refAllDecls(@This());
}
