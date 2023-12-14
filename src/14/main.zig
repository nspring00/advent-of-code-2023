const std = @import("std");

pub fn solve_1(inp: []const u8) u32 {
    const width = std.mem.indexOfScalar(u8, inp, '\n').? + 1;
    const height: u8 = @truncate((inp.len + 2) / width);

    var heights = std.mem.zeroes([100]u8);
    var c_idx: u8 = 0;
    var r_idx: u8 = 0;
    var result: u32 = 0;

    for (inp) |c| {
        switch (c) {
            '\r', '.' => {},
            '\n' => {
                c_idx = 0;
                r_idx += 1;
                continue;
            },
            '#' => heights[c_idx] = r_idx + 1,
            'O' => {
                result += height - heights[c_idx];
                heights[c_idx] += 1;
            },
            else => @panic("invalid input"),
        }
        c_idx += 1;
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
    try std.testing.expectEqual(@as(u32, 136), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 113486), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input));
}
