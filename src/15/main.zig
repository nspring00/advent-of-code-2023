const std = @import("std");

pub fn solve_1(inp: []const u8) u32 {
    var parts = std.mem.splitScalar(u8, inp, ',');
    var result: u32 = 0;

    while (parts.next()) |part| {
        result += hash(part);
    }

    return result;
}

fn hash(inp: []const u8) u32 {
    var result: u32 = 0;
    for (inp) |c| {
        result = ((result + c) * 17) % 256;
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
    try std.testing.expectEqual(@as(u32, 1320), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 505427), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input));
}
