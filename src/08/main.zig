const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;
const Allocator = std.mem.Allocator;

const Path = struct {
    left: []const u8,
    right: []const u8,
};

pub fn solve_1(inp: []const u8, allocator: Allocator) u32 {
    const directions = parse_directions(inp);
    var graph = parse_graph(inp, allocator);
    defer graph.deinit();

    var i: u32 = 0;
    var current: []const u8 = "AAA";
    const target = "ZZZ";

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

fn parse_directions(inp: []const u8) []const u8 {
    var lines = iter_lines(inp);
    return lines.next().?;
}

fn parse_graph(inp: []const u8, allocator: Allocator) std.StringHashMap(Path) {
    var lines = iter_lines(inp);
    _ = lines.next();
    _ = lines.next();

    var graph = std.StringHashMap(Path).init(allocator);

    while (lines.next()) |line| {
        const from = line[0..3];
        const to_l = line[7..10];
        const to_r = line[12..15];

        var path = Path{ .left = to_l, .right = to_r };
        graph.put(from, path) catch unreachable;
    }

    return graph;
}

fn path_len(graph: std.StringHashMap(Path), from: []const u8, directions: []const u8) u64 {
    var i: u64 = 0;
    var current = from;

    while (current[2] != 'Z') {
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

pub fn solve_2(inp: []const u8, allocator: Allocator) u64 {
    const directions = parse_directions(inp);
    var graph = parse_graph(inp, allocator);
    defer graph.deinit();

    var result: u64 = 1;
    var keys = graph.keyIterator();
    while (keys.next()) |key_ptr| {
        const key: []const u8 = key_ptr.*;

        if (key[2] != 'A') {
            continue;
        }

        result = utils.lcm(result, path_len(graph, key, directions));
    }

    return result;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 2), solve_1(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 6), solve_1("LLR\n\nAAA = (BBB, BBB)\nBBB = (AAA, ZZZ)\nZZZ = (ZZZ, ZZZ)", std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 18727), solve_1(input, std.testing.allocator));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u64, 6), solve_2("LR\n\n11A = (11B, XXX)\n11B = (XXX, 11Z)\n11Z = (11B, XXX)\n22A = (22B, XXX)\n22B = (22C, 22C)\n22C = (22Z, 22Z)\n22Z = (22B, 22B)\nXXX = (XXX, XXX)", std.testing.allocator));
    try std.testing.expectEqual(@as(u64, 18024643846273), solve_2(input, std.testing.allocator));
}
