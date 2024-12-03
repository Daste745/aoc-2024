const std = @import("std");
const print = std.debug.print;

const Mul = struct { a: i32, b: i32 };
const Data = struct {
    multiplications: std.ArrayList(Mul),

    pub fn deinit(self: Data) void {
        self.multiplications.deinit();
    }
};

fn parseInput(alloc: std.mem.Allocator, input: []const u8, followDosAndDonts: bool) !Data {
    var multiplications = std.ArrayList(Mul).init(alloc);
    var mulEnabled = true;

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        for (0..line.len) |i| {
            print("curr: {c}\n", .{line[i]});

            // Look for an opening - `mul(`
            if ((i + 4) < line.len and std.mem.eql(u8, line[i..(i + 4)], "mul(")) {
                if (followDosAndDonts and !mulEnabled) {
                    print("skipping possible mul()\n", .{});
                    continue;
                }

                print("enter: {s}\n", .{line[i..(i + 4)]});
                print("lookat: {c}\n", .{line[i + 4]});

                // Look for the closing bracket - `)`
                for ((i + 4)..(line.len)) |j| {
                    print("  curr: {c}\n", .{line[j]});
                    if (line[j] == ')') {
                        print("  exit: {c}\n", .{line[j]});
                        print("  expr: {s}\n", .{line[i..(j + 1)]});
                        const rawArgs = line[(i + 4)..j];
                        print("  args: {s}\n", .{rawArgs});

                        // Find all args inside brackets
                        var args = std.mem.splitScalar(u8, rawArgs, ',');
                        var parsedArgs = std.ArrayList(i32).init(alloc);
                        defer parsedArgs.deinit();
                        while (args.next()) |arg| {
                            const num = try std.fmt.parseInt(i32, arg, 10);
                            print("    arg: {d}\n", .{num});
                            try parsedArgs.append(num);
                        }
                        // There must be 2 args
                        if (parsedArgs.items.len != 2) break;

                        print("  args: {any}\n", .{parsedArgs.items});
                        try multiplications.append(.{ .a = parsedArgs.items[0], .b = parsedArgs.items[1] });

                        // Don't try to look for more closing brackets - we already found one
                        break;
                    }

                    // On an invalid character break the search immediately
                    if (line[j] == ',') continue;
                    if (line[j] < '0' or line[j] > '9') break;
                }
            }

            if ((i + 4) < line.len and std.mem.eql(u8, line[i..(i + 4)], "do()")) {
                print("  do()\n", .{});
                mulEnabled = true;
            }

            if ((i + 7) < line.len and std.mem.eql(u8, line[i..(i + 7)], "don't()")) {
                print("  don't()\n", .{});
                mulEnabled = false;
            }
        }
    }

    return .{ .multiplications = multiplications };
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
    const data = try parseInput(alloc, input, false);
    defer data.deinit();

    var total: i64 = 0;
    for (data.multiplications.items) |mul| {
        total += mul.a * mul.b;
    }
    return total;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !i64 {
    const data = try parseInput(alloc, input, true);
    defer data.deinit();

    var total: i64 = 0;
    for (data.multiplications.items) |mul| {
        total += mul.a * mul.b;
    }
    return total;
}

// Should do `2*4 + 5*5 + 11*8 + 8*5`
const exampleInputPart1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
test part1 {
    const result = try part1(std.testing.allocator, exampleInputPart1);
    try std.testing.expectEqual(161, result);
}

test "Part 1 single mul()" {
    const result = try part1(std.testing.allocator, "mul(2,4)");
    try std.testing.expectEqual(8, result);
}

test "Part 1 broken mul() followed by valid mul()" {
    const result = try part1(std.testing.allocator, "mul(10,2]mul(2,4)");
    try std.testing.expectEqual(8, result);
}

test "Part 1 mul() with mangled args followed by valid mul()" {
    const result = try part1(std.testing.allocator, "mul(10*2)mul(2,4)");
    try std.testing.expectEqual(8, result);
}

test "Part 1 mul() with single arg followed by valid mul()" {
    const result = try part1(std.testing.allocator, "mul(10)mul(2,4)");
    try std.testing.expectEqual(8, result);
}

// Should do `2*4 + 8*5`
const exampleInputPart2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
test part2 {
    const result = try part2(std.testing.allocator, exampleInputPart2);
    try std.testing.expectEqual(48, result);
}

test "Part 2 do() followed by mul()" {
    const result = try part2(std.testing.allocator, "do()mul(2,4)");
    try std.testing.expectEqual(8, result);
}

test "Part 2 don't() followed by mul()" {
    const result = try part2(std.testing.allocator, "don't()mul(2,4)");
    try std.testing.expectEqual(0, result);
}

test "Part 2 normal mul() followed by don't() and mul()" {
    const result = try part2(std.testing.allocator, "mul(2,4)don't()mul(2,10)");
    try std.testing.expectEqual(8, result);
}

test "Part 2 re-enabled do() followed by a mul()" {
    const result = try part2(std.testing.allocator, "don't()mul(2,10)do()mul(2,4)");
    try std.testing.expectEqual(8, result);
}

test "Part 2 re-enabled do() followed by multiple mul()" {
    const result = try part2(std.testing.allocator, "don't()mul(2,10)do()mul(2,4)mul(10,10)");
    try std.testing.expectEqual(108, result);
}
