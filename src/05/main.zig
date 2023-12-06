const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;
const Allocator = std.mem.Allocator;

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

const Interval = struct {
    from: u64,
    to: u64, // Exclusive

    pub fn format(
        self: Interval,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("[{},{}[", .{
            self.from, self.to,
        });
    }
};

pub fn solve_2(inp: []const u8, allocator: Allocator) u64 {
    var lines = iter_lines(inp);

    const intervals_str = lines.next() orelse unreachable;
    var intervals_iter = std.mem.split(u8, intervals_str[7..], " ");
    var current = std.ArrayList(Interval).init(allocator);
    var next = std.ArrayList(Interval).init(allocator);
    var remaining = std.ArrayList(Interval).init(allocator);
    defer current.deinit();
    defer next.deinit();
    defer remaining.deinit();

    while (intervals_iter.next()) |from_str| {
        const from = std.fmt.parseInt(u64, from_str, 10) catch unreachable;
        const amount = std.fmt.parseInt(u64, intervals_iter.next() orelse unreachable, 10) catch unreachable;
        next.append(Interval{ .from = from, .to = from + amount }) catch unreachable;
    }

    while (lines.next()) |line| {
        if (line.len == 0) {
            _ = lines.next(); // Skip empty line

            // Remaining intervals didn't get mapped
            while (current.popOrNull()) |interval| {
                next.append(interval) catch unreachable;
            }

            // Move contents of next to current and clear next
            const h = current;
            current = next;
            next = h;

            continue;
        }

        var line_iter = std.mem.split(u8, line, " ");
        const to = std.fmt.parseInt(u64, line_iter.next() orelse unreachable, 10) catch unreachable;
        const from = std.fmt.parseInt(u64, line_iter.next() orelse unreachable, 10) catch unreachable;
        const amount = std.fmt.parseInt(u64, line_iter.next() orelse unreachable, 10) catch unreachable;

        map_interval(from, to, amount, &current, &next, &remaining);
        const h = current;
        current = remaining;
        remaining = h;
    }

    // Remaining intervals didn't get mapped
    while (current.popOrNull()) |interval| {
        next.append(interval) catch unreachable;
    }

    // Get min item
    var result: u64 = std.math.maxInt(u64);
    for (next.items) |interval| {
        if (interval.from < result) {
            result = interval.from;
        }
    }
    return result;
}

fn map_interval(from: u64, to: u64, amount: u64, current: *std.ArrayList(Interval), next: *std.ArrayList(Interval), remaining: *std.ArrayList(Interval)) void {
    while (current.popOrNull()) |interval| {
        if (interval.to < from or interval.from >= from + amount) {
            remaining.append(interval) catch unreachable;
            continue;
        }

        const before = Interval{ .from = interval.from, .to = @min(interval.to, from) };
        const intersect = Interval{ .from = @max(interval.from, from), .to = @min(interval.to, from + amount) };
        const after = Interval{ .from = @max(interval.from, from + amount), .to = interval.to };

        if (before.from < before.to) {
            remaining.append(before) catch unreachable;
        }
        if (intersect.from < intersect.to) {
            const mapped = Interval{ .from = intersect.from - from + to, .to = intersect.to - from + to };
            next.append(mapped) catch unreachable;
        }
        if (after.from < after.to) {
            remaining.append(after) catch unreachable;
        }
    }
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u64, 35), solve_1(example_input));
    try std.testing.expectEqual(@as(u64, 313045984), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u64, 46), solve_2(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u64, 20283860), solve_2(input, std.testing.allocator));
}
