const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;
const Allocator = std.mem.Allocator;

const Path = struct {
    left: []const u8,
    right: []const u8,
};

pub fn solve_1(inp: []const u8, allocator: Allocator) u32 {
    var lines = iter_lines(inp);
    const directions = lines.next().?;
    _ = lines.next();

    var graph = std.StringHashMap(Path).init(allocator);
    defer graph.deinit();

    while (lines.next()) |line| {
        const from = line[0..3];
        const to_l = line[7..10];
        const to_r = line[12..15];

        var path = Path{ .left = to_l, .right = to_r };
        graph.put(from, path) catch unreachable;
    }

    var current: []const u8 = "AAA";
    const target = "ZZZ";

    var i: u32 = 0;

    while (!std.mem.eql(u8, current, target)) {
        const direction = directions[i % directions.len];
        i += 1;
        const path = graph.get(current).?;
        if (direction == 'L') {
            current = path.left;
        } else {
            current = path.right;
        }
    }

    return i;
}

pub fn solve_2(inp: []const u8, allocator: Allocator) u32 {
    _ = inp;
    _ = allocator;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");


test "solve_1" {
    try std.testing.expectEqual(@as(u32, 2), solve_1(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 6), solve_1("LLR\n\nAAA = (BBB, BBB)\nBBB = (AAA, ZZZ)\nZZZ = (ZZZ, ZZZ)", std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 18727), solve_1(input, std.testing.allocator));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input, std.testing.allocator));
}
