const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var leftNumbers = std.ArrayList(i32).init(allocator);
    var rightNumbers = std.ArrayList(i32).init(allocator);
    defer leftNumbers.deinit();
    defer rightNumbers.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        // TODO)) Is there a better way to do this?
        var parts = std.mem.splitScalar(u8, line, ' ');
        const leftNum = parts.next().?;
        while (parts.peek()) |peek| {
            if (std.mem.eql(u8, peek, "")) _ = parts.next()
            else break;
        }
        const rightNum = parts.next().?;

        const left = try std.fmt.parseInt(i32, leftNum, 10);
        const right = try std.fmt.parseInt(i32, rightNum, 10);
        try leftNumbers.append(left);
        try rightNumbers.append(right);
    }

    part1(try leftNumbers.clone(), try rightNumbers.clone());
    try part2(leftNumbers, rightNumbers);
}

fn part1(leftNumbers: std.ArrayList(i32), rightNumbers: std.ArrayList(i32)) void {
    defer leftNumbers.deinit();
    defer rightNumbers.deinit();

    std.mem.sort(i32, leftNumbers.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, rightNumbers.items, {}, comptime std.sort.asc(i32));

    var total: u64 = 0;
    for (leftNumbers.items, rightNumbers.items) |a, b| {
        const distance = @abs(a - b);
        total += distance;
        // print("l:{any} r:{any} d:{any}\n", .{a, b, distance});
    }
    print("Part 1: {d}\n", .{total});
}

fn part2(leftNumbers: std.ArrayList(i32), rightNumbers: std.ArrayList(i32)) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var rightCounts = std.AutoHashMap(i32, i32).init(allocator);
    defer rightCounts.deinit();
    for (rightNumbers.items) |item| {
        if (rightCounts.get(item)) |existingVal| {
            try rightCounts.put(item, existingVal + 1);
        } else {
            try rightCounts.put(item, 1);
        }
    }

    var total: i64 = 0;
    for (leftNumbers.items) |item| {
        if (rightCounts.get(item)) |count| {
            total += item * count;
        }
    }
    print("Part 2: {d}\n", .{total});
}
