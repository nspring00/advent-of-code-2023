const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;

pub fn solve_1(inp: []const u8) u32 {
    var lines = iter_lines(inp);
    var winning_nums = [10]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }; // There are at most 10 winning numbers
    var result: u32 = 0;

    while (lines.next()) |line| {
        const winning_nums_start = (std.mem.indexOfScalar(u8, line, ':') orelse unreachable) + 2;
        const winning_nums_end = (std.mem.indexOfScalar(u8, line, '|') orelse unreachable) - 1;
        const winning_nums_str = line[winning_nums_start..winning_nums_end];

        var winning_nums_iter = std.mem.splitScalar(u8, winning_nums_str, ' ');
        var num_i: usize = 0;
        while (winning_nums_iter.next()) |num_str| {
            if (num_str.len == 0) continue;
            const num = std.fmt.parseInt(u8, num_str, 10) catch unreachable;
            winning_nums[num_i] = num;
            num_i += 1;
        }
        const winning_nums_count = std.mem.indexOfScalar(u8, &winning_nums, 0) orelse 10;

        var matches: u32 = 0;
        var number_iter = std.mem.splitScalar(u8, line[winning_nums_end + 3 ..], ' ');
        while (number_iter.next()) |num_str| {
            if (num_str.len == 0) continue;
            const num = std.fmt.parseInt(u8, num_str, 10) catch unreachable;
            for (0..winning_nums_count) |win_num_i| {
                if (num == winning_nums[win_num_i]) {
                    matches += 1;
                    break;
                }
            }
        }

        const card_value: u32 = if (matches == 0) 0 else std.math.pow(u32, 2, matches - 1);
        result += card_value;
    }

    return result;
}

fn is_digit(c: u8) bool {
    return c >= '0' and c <= '9';
}

pub fn solve_2(inp: []const u8) u32 {
    _ = inp;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 13), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 20117), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input));
}
