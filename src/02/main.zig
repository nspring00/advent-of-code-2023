const std = @import("std");

const available_cubes = [_]u8{ 12, 13, 14 };

pub fn solve_1(inp: []const u8) u32 {
    var lines = std.mem.tokenizeScalar(u8, inp, '\n');
    var result: u32 = 0;
    var gamd_id: u32 = 0;
    game: while (lines.next()) |line| {
        gamd_id += 1;
        const required_cubes = min_required_cubes(line);
        for (0..3) |i| {
            if (required_cubes[i] > available_cubes[i]) {
                continue :game;
            }
        }
        result += gamd_id;
    }

    return result;
}

fn min_required_cubes(inp: []const u8) [3]u32 {
    // Skip the game id
    const i = (std.mem.indexOfScalar(u8, inp, ':') orelse unreachable) + 1;

    var required_cubes = [_]u32{ 0, 0, 0 };

    // Split the individual rounds
    var rounds = std.mem.tokenizeScalar(u8, inp[i..], ';');
    while (rounds.next()) |round| {
        var pulls = std.mem.tokenizeScalar(u8, round[1..], ',');
        var pulled_cubes = [_]u8{ 0, 0, 0 };
        while (pulls.next()) |pull| {
            var parts = std.mem.tokenizeScalar(u8, pull, ' ');
            const n_str = parts.next() orelse unreachable;
            const n = std.fmt.parseInt(u8, n_str, 10) catch unreachable;
            const color = parts.next() orelse unreachable;
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
            if (pulled_cubes[c_i] > required_cubes[c_i]) {
                required_cubes[c_i] = pulled_cubes[c_i];
            }
        }
    }

    return required_cubes;
}

pub fn solve_2(inp: []const u8) u32 {
    var lines = std.mem.tokenizeScalar(u8, inp, '\n');
    var result: u32 = 0;
    while (lines.next()) |line| {
        const required_cubes = min_required_cubes(line);
        result += required_cubes[0] * required_cubes[1] * required_cubes[2];
    }

    return result;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 8), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 2164), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 2286), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 69929), solve_2(input));
}
