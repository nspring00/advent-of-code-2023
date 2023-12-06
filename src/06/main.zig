const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;

pub fn solve_1(inp: []const u8) u32 {

    var lines = iter_lines(inp);
    const lines_1 = lines.next() orelse unreachable;
    const lines_2 = lines.next() orelse unreachable;

    const i_1 = std.mem.indexOfScalar(u8, lines_1, ':') orelse unreachable;
    const i_2 = std.mem.indexOfScalar(u8, lines_2, ':') orelse unreachable;

    var iter_1 = std.mem.splitScalar(u8, lines_1[i_1 + 1..], ' ');
    var iter_2 = std.mem.splitScalar(u8, lines_2[i_2 + 1..], ' ');

    var result: u32 = 1;
    while (iter_1.next()) |line_1| {
        if (line_1.len == 0) {
            continue;
        }

        while (iter_2.next()) |line_2| {
            if (line_2.len == 0) {
                continue;
            }

            var t = std.fmt.parseFloat(f32, line_1) catch unreachable;
            var d = std.fmt.parseFloat(f32, line_2) catch unreachable;

            result *= solve_quadratic(t, d);

            break;
        }
    }

    return result;
}

fn solve_quadratic(t: f32, d: f32) u32 {
    // Solve f(x) = (t-x)*x = d  <=>  (t-x)+x-d = 0  <=>  x^2 - tx + d = 0
    var sol_1 = (t - std.math.sqrt(t*t - 4*d)) / 2.0;
    if (sol_1 == @ceil(sol_1)) {
        sol_1 += 1.0;
    }
    var sol_2 = (t + std.math.sqrt(t*t - 4*d)) / 2.0;
    if (sol_2 == @floor(sol_2)) {
        sol_2 -= 1.0;
    }

    return @intFromFloat(@floor(sol_2) - @ceil(sol_1) + 1);
}

pub fn solve_2(inp: []const u8) u32 {
    _ = inp;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_quadratic" {
    try std.testing.expectEqual(@as(u32, 4), solve_quadratic(7, 9));
    try std.testing.expectEqual(@as(u32, 8), solve_quadratic(15, 40));
    try std.testing.expectEqual(@as(u32, 9), solve_quadratic(30, 200));
}

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 288), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 1660968), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input));
}
