const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
// const input = "16 13 11 10 7 5 8\n";


pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var reports = std.ArrayList(std.ArrayList(i32)).init(allocator);
    defer reports.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var report = std.ArrayList(i32).init(allocator);

        var parts = std.mem.splitScalar(u8, line, ' ');
        while (parts.next()) |part| {
            const num = try std.fmt.parseInt(i32, part, 10);
            try report.append(num);
        }

        try reports.append(report);
    }

    try part1(reports);
    try part2(reports);

    for (reports.items) |report| report.deinit();
}

fn part1(reports: std.ArrayList(std.ArrayList(i32))) !void {
    var total: u32 = 0;
    for (reports.items) |report| {
        if (try isSafe(report)) total += 1;
    }
    print("Part 1: {d}\n", .{total});
}

fn part2(reports: std.ArrayList(std.ArrayList(i32))) !void {
    var total: u32 = 0;

    for (reports.items) |report| {
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

    print("Part 2: {d}\n", .{total});
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
