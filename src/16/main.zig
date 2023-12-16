const std = @import("std");

const RIGHT: u8 = 0;
const DOWN: u8 = 1;
const LEFT: u8 = 2;
const UP: u8 = 3;

pub fn solve_1(inp: []const u8) u32 {
    const width: u16 = @truncate(std.mem.indexOfScalar(u8, inp, '\n').? + 1);
    const height: u16 = @truncate((inp.len + 2) / width);

    var visited = std.mem.zeroes([4 * 112 * 110]bool);
    var visited_slice = visited[0 .. 4 * height * width];

    return count_energized(inp, visited_slice, 0, RIGHT, width, height);
}

fn count_energized(inp: []const u8, visited: []bool, start_pos: u32, start_dir: u8, width: u16, height: u16) u32 {
    recurse(inp, visited, @bitCast(start_pos), start_dir, @bitCast(width), @bitCast(height));

    var result: u32 = 0;
    var i: usize = 0;
    while (i < visited.len) : (i += 4) {
        if (visited[i] or visited[i + 1] or visited[i + 2] or visited[i + 3]) {
            result += 1;
        }
    }

    for (0..visited.len) |j| {
        visited[j] = false;
    }

    return result;
}

fn recurse(inp: []const u8, visited: []bool, pos: i32, dir: u8, width: i16, height: i16) void {
    if (pos < 0) {
        return;
    }
    const pos_u: u32 = @bitCast(pos);
    if (pos_u >= inp.len or inp[pos_u] == '\r' or inp[pos_u] == '\n') {
        return;
    }

    const visited_key = pos_u * 4 + dir;
    if (visited[visited_key]) {
        return;
    }
    visited[visited_key] = true;

    var dir_new = dir;

    switch (inp[pos_u]) {
        '.' => {},
        '|' => {
            if (dir == RIGHT or dir == LEFT) {
                recurse(inp, visited, pos - width, UP, width, height);
                recurse(inp, visited, pos + width, DOWN, width, height);
                return;
            }
        },
        '-' => {
            if (dir == DOWN or dir == UP) {
                recurse(inp, visited, pos - 1, LEFT, width, height);
                recurse(inp, visited, pos + 1, RIGHT, width, height);
                return;
            }
        },
        '/' => {
            dir_new = switch (dir) {
                RIGHT => UP,
                DOWN => LEFT,
                LEFT => DOWN,
                UP => RIGHT,
                else => unreachable,
            };
        },
        '\\' => {
            dir_new = switch (dir) {
                RIGHT => DOWN,
                DOWN => RIGHT,
                LEFT => UP,
                UP => LEFT,
                else => unreachable,
            };
        },
        else => unreachable,
    }

    const pos_new: i32 = pos + switch (dir_new) {
        RIGHT => 1,
        DOWN => width,
        LEFT => -1,
        UP => -width,
        else => unreachable,
    };

    recurse(inp, visited, pos_new, dir_new, width, height);
}

pub fn solve_2(inp: []const u8) u32 {
    const width: u16 = @truncate(std.mem.indexOfScalar(u8, inp, '\n').? + 1);
    const content_width: u16 = @truncate(std.mem.indexOfAny(u8, inp, "\r\n").?);
    const height: u16 = @truncate((inp.len + 2) / width);

    var visited = std.mem.zeroes([4 * 112 * 110]bool);
    var visited_slice = visited[0 .. 4 * height * width];

    var max_result: u32 = 0;

    for (0..height) |y| {
        const val_1 = count_energized(inp, visited_slice, @truncate(y * width), RIGHT, width, height);
        if (val_1 > max_result) {
            max_result = val_1;
        }
        const val_2 = count_energized(inp, visited_slice, @truncate(y * width + content_width - 1), LEFT, width, height);
        if (val_2 > max_result) {
            max_result = val_2;
        }
    }

    for (0..width) |x| {
        const val_1 = count_energized(inp, visited_slice, @truncate(x), DOWN, width, height);
        if (val_1 > max_result) {
            max_result = val_1;
        }
        const val_2 = count_energized(inp, visited_slice, @truncate(x + (height - 1) * width), UP, width, height);
        if (val_2 > max_result) {
            max_result = val_2;
        }
    }

    return max_result;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1_test" {
    // Test -
    try std.testing.expectEqual(@as(u32, 4), solve_1(".\\.\n...\n..."));
    try std.testing.expectEqual(@as(u32, 5), solve_1(".\\.\n.-.\n..."));
    try std.testing.expectEqual(@as(u32, 6), solve_1(".\\.\n...\n.-."));
    try std.testing.expectEqual(@as(u32, 6), solve_1(".\\.\n.|.\n.-."));

    // Test |
    try std.testing.expectEqual(@as(u32, 6), solve_1("\\...\n\\.|.\n...."));
    try std.testing.expectEqual(@as(u32, 7), solve_1("\\...\n\\..|\n...."));
    try std.testing.expectEqual(@as(u32, 7), solve_1("\\...\n\\--|\n...."));

    // Test \
    try std.testing.expectEqual(@as(u32, 7), solve_1("\\...\n\\\\..\n.\\\\.\n..\\."));

    // Test /
    try std.testing.expectEqual(@as(u32, 10), solve_1("...\\\n..//\n.//.\n//.."));
}

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 46), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 7477), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 51), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 7853), solve_2(input));
}
