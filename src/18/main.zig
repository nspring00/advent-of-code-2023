const std = @import("std");
const utils = @import("../utils.zig");
const Allocator = std.mem.Allocator;
const iter_lines = utils.iter_lines;

const Point = struct {
    x: i64,
    y: i64,
};

pub fn solve_1(inp: []const u8, allocator: Allocator) u32 {

    // Uses combination of Shoelace formula and Pick's theorem
    // Necessary because the area consists of blocks of 1x1 and not a continuous area
    // --> adjust for thickness of the boundary

    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();

    points.append(Point{ .x = 0, .y = 0 }) catch unreachable;

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
    }

    return @truncate(compute_area(points.items));
}

fn compute_area(points: []Point) u64 {
    var area: i64 = 0;

    var boundary_len: u64 = 0;
    for (0..points.len) |i| {
        const prev_point = points[(i + points.len - 1) % points.len];
        const next_point = points[(i + 1) % points.len];
        const point = points[i];
        boundary_len += @abs(point.x - prev_point.x) + @abs(point.y - prev_point.y);
        area += point.x * (prev_point.y - next_point.y);
    }

    const areaU = @abs(@divFloor(area, 2));

    // Correct area for thickness of the boundary using Pick's theorem
    return areaU + @divFloor(boundary_len, 2) + 1;
}

pub fn solve_2(inp: []const u8, allocator: Allocator) u64 {
    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();

    points.append(Point{ .x = 0, .y = 0 }) catch unreachable;

    var lines_iter = iter_lines(inp);
    while (lines_iter.next()) |line| {
        var line_iter = std.mem.split(u8, line, " ");
        _ = line_iter.next() orelse unreachable;
        _ = line_iter.next() orelse unreachable;
        const color = line_iter.next() orelse unreachable;
        const direction = color[7];
        const distance = std.fmt.parseInt(i32, color[2..7], 16) catch unreachable;
        const last_point = points.items[points.items.len - 1];
        var new_point = Point{ .x = last_point.x, .y = last_point.y };
        switch (direction) {
            '0' => new_point.x += distance,
            '2' => new_point.x -= distance,
            '3' => new_point.y += distance,
            '1' => new_point.y -= distance,
            else => unreachable,
        }

        points.append(new_point) catch unreachable;
    }

    return compute_area(points.items);
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 62), solve_1(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 58550), solve_1(input, std.testing.allocator));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u64, 952408144115), solve_2(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u64, 47452118468566), solve_2(input, std.testing.allocator));
}
