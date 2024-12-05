const std = @import("std");
const ArrayList = std.ArrayList;
const print = std.debug.print;
const splitScalar = std.mem.splitScalar;
const eql = std.mem.eql;

const Data = struct {
    pub fn deinit(self: Data) void {
        _ = self;
    }
};

fn parseInput(alloc: std.mem.Allocator, input: []const u8) !Data {
    _ = alloc; // autofix
    var lines = splitScalar(u8, input, '\n');

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        // Parsing
    }

    return .{};
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const input = @embedFile("input.txt");

    print("Part 1: {d}\n", .{try part1(alloc, input)});
    print("Part 2: {d}\n", .{try part2(alloc, input)});
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !i64 {
    const data = try parseInput(alloc, input);
    defer data.deinit();

    const total: i64 = 0;
    // Solution
    return total;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !i64 {
    const data = try parseInput(alloc, input);
    defer data.deinit();

    const total: i64 = 0;
    // Solution
    return total;
}

const exampleInput =
    \\
;

test part1 {
    const result = try part1(std.testing.allocator, exampleInput);
    try std.testing.expectEqual(-1, result);
}

test part2 {
    const result = try part2(std.testing.allocator, exampleInput);
    try std.testing.expectEqual(-1, result);
}
