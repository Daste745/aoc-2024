const std = @import("std");
const print = std.debug.print;

const Data = struct {
    reports: std.ArrayList(std.ArrayList(i32)),

    pub fn deinit(self: Data) void {
        for (self.reports.items) |report| report.deinit();
        self.reports.deinit();
    }
};

fn parseInput(alloc: std.mem.Allocator, input: []const u8) !Data {
    var reports = std.ArrayList(std.ArrayList(i32)).init(alloc);

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var report = std.ArrayList(i32).init(alloc);
        var parts = std.mem.splitScalar(u8, line, ' ');
        while (parts.next()) |part| {
            const num = try std.fmt.parseInt(i32, part, 10);
            try report.append(num);
        }

        try reports.append(report);
    }

    return .{ .reports = reports };
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

    var total: i64 = 0;
    for (data.reports.items) |report| {
        if (try isSafe(report)) total += 1;
    }
    return total;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !i64 {
    const data = try parseInput(alloc, input);
    defer data.deinit();

    var total: i64 = 0;

    for (data.reports.items) |report| {
        var reportMutation = try report.clone();
        defer reportMutation.deinit();
        for (0..(report.items.len + 1)) |i| {
            const safe = try isSafe(reportMutation);
            // print("[{d}] {any} -> {any}\n", .{i, reportMutation.items, safe});

            if (safe) {
                total += 1;
                break;
            }
            if (i == report.items.len) break;

            // Re-clone the report and remove one element
            reportMutation.deinit();
            reportMutation = try report.clone();
            _ = reportMutation.orderedRemove(i);
        }
        // print("\n", .{});
    }

    return total;
}

fn isSafe(report: std.ArrayList(i32)) !bool {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var differences = std.ArrayList(i32).init(allocator);
    defer differences.deinit();
    for (0..(report.items.len - 1)) |i| {
        const diff = report.items[i] - report.items[i + 1];
        try differences.append(diff);
    }

    var positive: u32 = 0;
    var negative: u32 = 0;
    for (differences.items) |diff| {
        if (diff == 0) return false;
        if (diff > 3 or diff < -3) return false;
        if (diff > 0) positive += 1;
        if (diff < 0) negative += 1;
    }
    if (positive == 0 and negative > 0) return true;
    if (negative == 0 and positive > 0) return true;

    return false;
}

const exampleInput =
    \\7 6 4 2 1
    \\1 2 7 8 9
    \\9 7 6 2 1
    \\1 3 2 4 5
    \\8 6 4 4 1
    \\1 3 6 7 9
;

test part1 {
    const result = try part1(std.testing.allocator, exampleInput);
    try std.testing.expectEqual(2, result);
}

test part2 {
    const result = try part2(std.testing.allocator, exampleInput);
    try std.testing.expectEqual(4, result);
}
