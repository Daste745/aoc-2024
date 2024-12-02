const std = @import("std");
const print = std.debug.print;

const Data = struct {
    left: std.ArrayList(i32),
    right: std.ArrayList(i32),

    pub fn deinit(self: Data) void {
        self.left.deinit();
        self.right.deinit();
    }
};

fn parseInput(alloc: std.mem.Allocator, input: []const u8) !Data {
    var left = std.ArrayList(i32).init(alloc);
    var right = std.ArrayList(i32).init(alloc);

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        // TODO)) Is there a better way to do this?
        var parts = std.mem.splitScalar(u8, line, ' ');
        const leftRaw = parts.next().?;
        while (parts.peek()) |peek| {
            if (std.mem.eql(u8, peek, "")) _ = parts.next() else break;
        }
        const rightRaw = parts.next().?;

        try left.append(try std.fmt.parseInt(i32, leftRaw, 10));
        try right.append(try std.fmt.parseInt(i32, rightRaw, 10));
    }

    return .{ .left = left, .right = right };
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

    std.mem.sort(i32, data.left.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, data.right.items, {}, comptime std.sort.asc(i32));

    var total: i64 = 0;
    for (data.left.items, data.right.items) |a, b| {
        const distance = @abs(a - b);
        total += distance;
        // print("l:{any} r:{any} d:{any}\n", .{a, b, distance});
    }
    return total;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !i64 {
    const data = try parseInput(alloc, input);
    defer data.deinit();

    var rightCounts = std.AutoHashMap(i32, i32).init(alloc);
    defer rightCounts.deinit();
    for (data.right.items) |item| {
        if (rightCounts.get(item)) |existingVal| {
            try rightCounts.put(item, existingVal + 1);
        } else {
            try rightCounts.put(item, 1);
        }
    }

    var total: i64 = 0;
    for (data.left.items) |item| {
        if (rightCounts.get(item)) |count| {
            total += item * count;
        }
    }
    return total;
}

const exampleInput =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
;

test part1 {
    const result = try part1(std.testing.allocator, exampleInput);
    try std.testing.expectEqual(11, result);
}

test part2 {
    const result = try part2(std.testing.allocator, exampleInput);
    try std.testing.expectEqual(31, result);
}
