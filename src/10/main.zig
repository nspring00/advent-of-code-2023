const std = @import("std");

pub fn solve_1(inp: []const u8) u32 {
    const width = std.mem.indexOfScalar(u8, inp, '\n').? + 1;
    const start = std.mem.indexOfScalar(u8, inp, 'S').?;

    // Find 2 adjacent pipes
    var pipe1: usize = 0;
    var last1 = start;
    var pipe2: usize = 0;
    var last2 = start;
    var len: u32 = 1;

    const upper = start - width;
    if (inp[upper] == '|' or inp[upper] == 'F' or inp[upper] == '7') {
        pipe1 = upper;
    }
    const lower = start + width;
    if (inp[lower] == '|' or inp[lower] == 'J' or inp[lower] == 'L') {
        if (pipe1 == 0) {
            pipe1 = lower;
        } else {
            pipe2 = lower;
        }
    }
    const left = start - 1;
    if (inp[left] == '-' or inp[left] == 'F' or inp[left] == 'L') {
        if (pipe1 == 0) {
            pipe1 = left;
        } else {
            pipe2 = left;
        }
    }
    const right = start + 1;
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
    const width = std.mem.indexOfScalar(u8, inp, '\n').? + 1;
    const start = std.mem.indexOfScalar(u8, inp, 'S').?;
    var current: usize = 0;
    var last: usize = 0;
    var prev = start;

    // Find 2 adjacent pipes
    const upper = start - width;
    if (inp[upper] == '|' or inp[upper] == 'F' or inp[upper] == '7') {
        current = upper;
    }
    const lower = start + width;
    if (inp[lower] == '|' or inp[lower] == 'J' or inp[lower] == 'L') {
        if (current == 0) {
            current = lower;
        } else {
            last = lower;
        }
    }
    const left = start - 1;
    if (inp[left] == '-' or inp[left] == 'F' or inp[left] == 'L') {
        if (current == 0) {
            current = left;
        } else {
            last = left;
        }
    }
    const right = start + 1;
    if (inp[right] == '-' or inp[right] == '7' or inp[right] == 'J') {
        if (current == 0) {
            current = right;
        } else {
            last = right;
        }
    }

    // Determine the pipe shape behind 'S'
    var start_char: u8 = undefined;
    if (current == upper and last == lower) {
        start_char = '|';
    } else if (current == upper and last == left) {
        start_char = 'J';
    } else if (current == upper and last == right) {
        start_char = 'L';
    } else if (current == lower and last == left) {
        start_char = '7';
    } else if (current == lower and last == right) {
        start_char = 'F';
    } else if (current == left and last == right) {
        start_char = '-';
    } else {
        unreachable;
    }

    // Create a mask of all pipes that are part of the loop
    var pipe_mask = std.mem.zeroes([20000]bool);
    pipe_mask[start] = true;
    pipe_mask[last] = true;
    while (current != last) {
        pipe_mask[current] = true;
        const h = current;
        current = next_pipe(inp, current, prev, width);
        prev = h;
    }

    var inside = false;
    var result: u32 = 0;
    var start_horizontal_pipe: u8 = 0;

    for (0..inp.len) |i| {
        var c = inp[i];
        if (i == start) {
            c = start_char;
        }

        if (!pipe_mask[i] and inside) {
            result += 1;
        }

        if (pipe_mask[i]) {
            // Mark start of horizontal pipe
            if (c == 'F' or c == 'L') {
                start_horizontal_pipe = c;
            }
            // Needed to disinguish between cases L---J and L---7
            if ((c == '7' and start_horizontal_pipe == 'L') or (c == 'J' and start_horizontal_pipe == 'F') or c == '|') {
                inside = !inside;
            }
        }
    }

    return result;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 4), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 8), solve_1("..F7.\n.FJ|.\nSJ.L7\n|F--J\nLJ..."));
    try std.testing.expectEqual(@as(u32, 6738), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u64, 1), solve_2(example_input));
    try std.testing.expectEqual(@as(u64, 4), solve_2("...........\n.S-------7.\n.|F-----7|.\n.||.....||.\n.||.....||.\n.|L-7.F-J|.\n.|..|.|..|.\n.L--J.L--J.\n..........."));
    try std.testing.expectEqual(@as(u64, 4), solve_2("..........\n.S------7.\n.|F----7|.\n.||....||.\n.||....||.\n.|L-7F-J|.\n.|II||II|.\n.L--JL--J.\n.........."));
    try std.testing.expectEqual(@as(u64, 8), solve_2(".F----7F7F7F7F-7....\n.|F--7||||||||FJ....\n.||.FJ||||||||L7....\nFJL7L7LJLJ||LJ.L-7..\nL--J.L7...LJS7F-7L7.\n....F-J..F7FJ|L7L7L7\n....L7.F7||L7|.L7L7|\n.....|FJLJ|FJ|F7|.LJ\n....FJL-7.||.||||...\n....L---J.LJ.LJLJ..."));
    try std.testing.expectEqual(@as(u64, 579), solve_2(input));
}
