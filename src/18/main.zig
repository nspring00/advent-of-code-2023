const std = @import("std");
const utils = @import("../utils.zig");
const Allocator = std.mem.Allocator;
const iter_lines = utils.iter_lines;

const Point = struct {
    x: i32,
    y: i32,
};

pub fn solve_1(inp: []const u8, allocator: Allocator) u32 {

    // Uses combination of Shoelace formula and Pick's theorem
    // Necessary because the area consists of blocks of 1x1 and not a continuous area
    // --> adjust for thickness of the boundary

    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();

    points.append(Point{ .x = 0, .y = 0 }) catch unreachable;

    var boundary_len: i32 = 0;

    var lines_iter = iter_lines(inp);
    while (lines_iter.next()) |line| {
        var line_iter = std.mem.split(u8, line, " ");
        const direction = (line_iter.next() orelse unreachable)[0];
        const distance = std.fmt.parseInt(i32, line_iter.next() orelse unreachable, 10) catch unreachable;
        const last_point = points.items[points.items.len - 1];
        var new_point = Point{ .x = last_point.x, .y = last_point.y };
        switch (direction) {
            'R' => new_point.x += distance,
            'L' => new_point.x -= distance,
            'U' => new_point.y += distance,
            'D' => new_point.y -= distance,
            else => unreachable,
        }

        points.append(new_point) catch unreachable;
        boundary_len += distance;
    }

    var area: i32 = 0;

    for (0..points.items.len) |i| {
        const prev_point = points.items[(i + points.items.len - 1) % points.items.len];
        const next_point = points.items[(i + 1) % points.items.len];
        const point = points.items[i];
        area += point.x * (prev_point.y - next_point.y);
    }

    const areaU = @abs(@divFloor(area, 2));
    const i: u32 = areaU - @divFloor(@abs(boundary_len), 2) + 1;

    return @abs(boundary_len) + i;
}

pub fn solve_2(inp: []const u8, allocator: Allocator) u32 {
    _ = inp;
    _ = allocator;

    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 62), solve_1(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 58550), solve_1(input, std.testing.allocator));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input, std.testing.allocator));
}
