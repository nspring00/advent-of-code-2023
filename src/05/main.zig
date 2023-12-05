const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;

pub fn solve_1(inp: []const u8) u64 {
    var lines = iter_lines(inp);

    const seeds_str = lines.next() orelse unreachable;
    var seeds = std.mem.split(u8, seeds_str[7..], " ");
    var items = std.mem.zeroes([20]u64);
    var next_items = std.mem.zeroes([20]u64);
    var i: usize = 0;
    while (seeds.next()) |seed| {
        next_items[i] = std.fmt.parseInt(u32, seed, 10) catch unreachable;
        i += 1;
    }
    const nr_of_items = i;

    while (lines.next()) |line| {
        if (line.len == 0) {
            _ = lines.next(); // Skip empty line
            // Move contents of items_next to items
            for (next_items, 0..) |item, item_i| {
                items[item_i] = item;
            }
            continue;
        }

        var line_iter = std.mem.split(u8, line, " ");
        const to = std.fmt.parseInt(u64, line_iter.next() orelse unreachable, 10) catch unreachable;
        const from = std.fmt.parseInt(u64, line_iter.next() orelse unreachable, 10) catch unreachable;
        const amount = std.fmt.parseInt(u64, line_iter.next() orelse unreachable, 10) catch unreachable;

        for (0..nr_of_items) |item_i| {
            const item = items[item_i];
            if (item >= from and item < from + amount) {
                next_items[item_i] = item - from + to;
            }
        }
    }

    // Get min item
    var result: u64 = std.math.maxInt(u64);
    for (0..nr_of_items) |item_i| {
        const item = next_items[item_i];
        if (item < result) {
            result = item;
        }
    }
    return result;
}

pub fn solve_2(inp: []const u8) u32 {
    _ = inp;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u64, 35), solve_1(example_input));
    try std.testing.expectEqual(@as(u64, 313045984), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input));
}
