const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const Rule = struct { x: i32, y: i32 };
const Data = struct {
    rules: ArrayList(Rule),
    pages: ArrayList(ArrayList(i32)),

    pub fn deinit(self: Data) void {
        self.rules.deinit();
        for (self.pages.items) |page| page.deinit();
        self.pages.deinit();
    }
};

fn parseInput(alloc: std.mem.Allocator, input: []const u8) !Data {
    var rules = ArrayList(Rule).init(alloc);
    var pages = ArrayList(ArrayList(i32)).init(alloc);

    var lines = std.mem.splitScalar(u8, input, '\n');
    var parsingRules = true;
    while (lines.next()) |line| {
        if (line.len == 0) {
            // Midpoint
            if (parsingRules) {
                parsingRules = false;
                continue;
            }
            // EOF
            parsingRules = false;
            continue;
        }

        if (parsingRules) {
            var parts = std.mem.splitScalar(u8, line, '|');
            const x = try std.fmt.parseInt(u8, parts.next().?, 10);
            const y = try std.fmt.parseInt(u8, parts.next().?, 10);
            // print("rule {d} -> {d}\n", .{ x, y });
            try rules.append(.{ .x = x, .y = y });
        } else {
            var page = ArrayList(i32).init(alloc);
            var parts = std.mem.splitScalar(u8, line, ',');
            while (parts.next()) |part| {
                try page.append(try std.fmt.parseInt(u8, part, 10));
            }
            // print("page {any}\n", .{page.items});
            try pages.append(page);
        }
    }

    return .{
        .rules = rules,
        .pages = pages,
    };
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
    var pageIdx: usize = 0;
    for (data.pages.items) |page| {
        var valid = true;
        for (page.items, 0..(page.items.len)) |item, i| {
            const itemsAfter = page.items[(i + 1)..];
            // print("[{d:02}] {d}: {any}\n", .{ pageIdx, item, itemsAfter });
            for (itemsAfter) |itemAfter| {
                for (data.rules.items) |rule| {
                    // ItemAfter should be on y, not x
                    if (rule.x == itemAfter and rule.y == item) {
                        valid = false;
                        break;
                    }
                }
                if (!valid) break;
            }
            if (!valid) break;
        }

        if (valid) {
            const middleIdx = page.items.len / 2;
            total += page.items[middleIdx];
        }
        pageIdx += 1;
    }
    return total;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !i64 {
    const data = try parseInput(alloc, input);
    defer data.deinit();

    var total: i64 = 0;
    var pageIdx: usize = 0;
    for (data.pages.items) |page| {
        // print(" [{d:02}] {any}\n", .{ pageIdx, page.items });

        var valid = true;
        for (0..page.items.len) |i| {
            const itemsAfter = page.items[(i + 1)..];
            // print("[{d:02}] {d}: {any}\n", .{ pageIdx, page.items[i], itemsAfter });
            for (0..itemsAfter.len) |j| {
                for (data.rules.items) |rule| {
                    // ItemAfter should be on y, not x
                    if (rule.x == itemsAfter[j] and rule.y == page.items[i]) {
                        // print("swap({d}, {d}) -> ", .{ page.items[i], page.items[i + j + 1] });
                        std.mem.swap(i32, &page.items[i], &page.items[i + j + 1]);
                        // print("{any}\n", .{page.items});
                        valid = false;
                    }
                }
            }
        }

        // print(" [{d:02}] {any}\n", .{ pageIdx, page.items });
        if (!valid) {
            const middleIdx = page.items.len / 2;
            total += page.items[middleIdx];
        }
        pageIdx += 1;
    }
    return total;
}

const exampleInput =
    \\47|53
    \\97|13
    \\97|61
    \\97|47
    \\75|29
    \\61|13
    \\75|53
    \\29|13
    \\97|29
    \\53|29
    \\61|53
    \\97|53
    \\61|29
    \\47|13
    \\75|47
    \\97|75
    \\47|61
    \\75|61
    \\47|29
    \\75|13
    \\53|13
    \\
    \\75,47,61,53,29
    \\97,61,53,29,13
    \\75,29,13
    \\75,97,47,61,53
    \\61,13,29
    \\97,13,75,29,47
;

test part1 {
    const result = try part1(std.testing.allocator, exampleInput);
    try std.testing.expectEqual(143, result);
}

test part2 {
    const result = try part2(std.testing.allocator, exampleInput);
    try std.testing.expectEqual(123, result);
}
