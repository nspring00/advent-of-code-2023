const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;

pub fn solve_1(inp: []const u8) u32 {

    const width = std.mem.indexOfScalar(u8, inp, '\n').? + 1;
    const start = std.mem.indexOfScalar(u8, inp, 'S').?;

    // Find 2 adjacent pipes
    var pipe1: usize = 0;
    var last1 = start;
    var pipe2: usize = 0;
    var last2 = start;
    var len: u32 = 1;

    var upper = start - width;
    if (inp[upper] == '|' or inp[upper] == 'F' or inp[upper] == '7') {
        pipe1 = upper;
        last1 = upper;
    }
    var lower = start + width;
    if (inp[lower] == '|' or inp[lower] == 'J' or inp[lower] == 'L') {
        if (pipe1 == 0) {
            pipe1 = lower;
        } else {
            pipe2 = lower;
        }
    }
    var left = start - 1;
    if (inp[left] == '-' or inp[left] == 'F' or inp[left] == 'L') {
        if (pipe1 == 0) {
            pipe1 = left;
        } else {
            pipe2 = left;
        }
    }
    var right = start + 1;
    if (inp[right] == '-' or inp[right] == '7' or inp[right] == 'J') {
        if (pipe1 == 0) {
            pipe1 = right;
        } else {
            pipe2 = right;
        }
    }

    // Find the next pipe in both directions until they meet
    while (pipe1 != pipe2 and pipe1 != last2) {
        const h1 = last1;
        const h2 = last2;
        last1 = pipe1;
        last2 = pipe2;
        pipe1 = next_pipe(inp, pipe1, h1, width);
        pipe2 = next_pipe(inp, pipe2, h2, width);
        len += 1;
    }

    return len;
}

fn next_pipe(inp: []const u8, pipe: usize, last: usize, width: usize) usize {
    const cur = inp[pipe];

    // Check upper
    if ((cur == '|' or cur == 'J' or cur == 'L') and pipe >= width) {
        var upper = pipe - width;
        if (upper != last and (inp[upper] == '|' or inp[upper] == 'F' or inp[upper] == '7')) {
            return upper;
        }
    }

    // Check lower
    var lower = pipe + width;
    if ((cur == '|' or cur == 'F' or cur == '7') and lower < inp.len and lower != last and (inp[lower] == '|' or inp[lower] == 'J' or inp[lower] == 'L')) {
        return lower;
    }

    // Check left
    if ((cur == '-' or cur == '7' or cur == 'J') and pipe > 0) {
        var left = pipe - 1;
        if (left != last and (inp[left] == '-' or inp[left] == 'F' or inp[left] == 'L')) {
            return left;
        }
    }

    // Check right
    var right = pipe + 1;
    if ((cur == '-' or cur == 'F' or cur == 'L') and right < inp.len and right != last and (inp[right] == '-' or inp[right] == '7' or inp[right] == 'J')) {
        return right;
    }

    unreachable;
}

pub fn solve_2(inp: []const u8) u64 {
    _ = inp;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 4), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 8), solve_1("..F7.\n.FJ|.\nSJ.L7\n|F--J\nLJ..."));
    try std.testing.expectEqual(@as(u32, 6738), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u64, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u64, 0), solve_2(input));
}
