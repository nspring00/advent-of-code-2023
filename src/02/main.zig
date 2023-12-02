const std = @import("std");

const available_cubes = [_]u8{ 12, 13, 14 };

pub fn solve_1(inp: []const u8) u32 {
    var lines = std.mem.tokenizeScalar(u8, inp, '\n');
    var result: u32 = 0;
    var i: u32 = 1;
    while (lines.next()) |line| {
        if (validate_game(line)) {
            result += i;
        }
        i += 1;
    }

    return result;
}

fn validate_game(inp: []const u8) bool {
    // Skip the game id
    const i = (std.mem.indexOfScalar(u8, inp, ':') orelse return false) + 1;

    // Split the individual rounds
    var rounds = std.mem.tokenizeScalar(u8, inp[i..], ';');
    while (rounds.next()) |round| {
        var pulls = std.mem.tokenizeScalar(u8, round[1..], ',');
        var pulled_cubes = [_]u8{ 0, 0, 0 };
        while (pulls.next()) |pull| {
            var parts = std.mem.tokenizeScalar(u8, pull, ' ');
            const n_str = parts.next() orelse return false;
            const n = std.fmt.parseInt(u8, n_str, 10) catch unreachable;
            const color = parts.next() orelse return false;
            var color_id: usize = undefined;
            if (std.mem.eql(u8, color, "red")) {
                color_id = 0;
            } else if (std.mem.eql(u8, color, "green")) {
                color_id = 1;
            } else if (std.mem.eql(u8, color, "blue")) {
                color_id = 2;
            } else {
                unreachable;
            }

            pulled_cubes[color_id] += n;
        }

        for (0..3) |c_i| {
            if (pulled_cubes[c_i] > available_cubes[c_i]) {
                return false;
            }
        }
    }

    return true;
}

pub fn solve_2(inp: []const u8) u32 {
    _ = inp;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 8), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 2164), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input));
}
