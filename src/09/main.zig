const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;

pub fn solve_1(inp: []const u8) u32 {
    var lines = iter_lines(inp);
    var result: u32 = 0;

    while (lines.next()) |line| {
        const result_s: i32 = @bitCast(result);
        const line_res = predict_value(line);

        result = @bitCast(result_s + line_res);
    }

    return result;
}

fn predict_value(inp: []const u8) i32 {
    var buf = std.mem.zeroes([21]i32);
    var num_iter = std.mem.splitScalar(u8, inp, ' ');
    var num_count: u8 = 0;

    while (num_iter.next()) |num| {
        buf[num_count] = std.fmt.parseInt(i32, num, 10) catch unreachable;
        num_count += 1;
    }

    var running = true;
    while (running) {
        running = false;
        for (1..num_count) |num_i| {
            buf[num_i - 1] = buf[num_i] - buf[num_i - 1];
            if (buf[num_i - 1] != 0) {
                running = true;
            }
        }

        num_count -= 1;
    }

    var result: i32 = 0;
    for (buf) |num| {
        result += num;
    }
    return result;
}

pub fn solve_2(inp: []const u8) u64 {
    _ = inp;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 114), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 1884768153), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u64, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u64, 0), solve_2(input));
}
