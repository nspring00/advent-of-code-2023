const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;

pub fn solve_1(inp: []const u8) u32 {
    var result: u32 = 0;
    var lines = iter_lines(inp);
    while (lines.next()) |line| {
        result += process_line(line);
    }
    return result;
}

fn process_line(line: []const u8) u32 {
    const str_end = std.mem.indexOfScalar(u8, line, ' ').?;
    const str = line[0..str_end];
    var group_iter = std.mem.splitScalar(u8, line[str_end + 1 ..], ',');
    var groups = std.mem.zeroes([6]u8);
    var i: usize = 0;
    while (group_iter.next()) |group| {
        groups[i] = std.fmt.parseInt(u8, group, 10) catch unreachable;
        i += 1;
    }

    return group_permutations(str, groups[0..i]);
}

fn group_permutations(line: []const u8, groups: []u8) u32 {
    var str = line;

    const next_hash = std.mem.indexOfAny(u8, str, "#?");
    if (next_hash == null) {
        if (groups.len == 0) {
            return 1;
        } else {
            return 0;
        }
    }

    str = str[next_hash.?..];

    // Case first char is #
    if (str[0] == '#') {
        return group_permutations_hash(str, groups);
    }

    // Case first char is ?
    return group_permutations_hash(str, groups) + group_permutations(str[1..], groups);
}

fn group_permutations_hash(line: []const u8, groups: []u8) u32 {
    if (line[0] == '.') {
        @panic("This should not happen");
    }

    var str = line;

    if (groups.len == 0) {
        return 0;
    }

    // Must use first group
    const group_len = groups[0];
    if (str.len < group_len) {
        return 0;
    }

    // If not all chars in group are # or ? return 0
    for (0..group_len) |i| {
        if (str[i] != '#' and str[i] != '?') {
            return 0;
        }
    }

    // Fully parsed
    if (str.len == group_len) {
        if (groups.len == 1) {
            return 1;
        } else {
            return 0;
        }
    }

    // After group must be . or ?
    if (str[group_len] == '#') {
        return 0;
    }

    // Recurse
    return group_permutations(str[group_len + 1 ..], groups[1..]);
}

pub fn solve_2(inp: []const u8) u32 {
    _ = inp;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "process_line" {
    try std.testing.expectEqual(@as(u32, 1), process_line("???.### 1,1,3"));
    try std.testing.expectEqual(@as(u32, 4), process_line(".??..??...?##. 1,1,3"));
    try std.testing.expectEqual(@as(u32, 1), process_line("?#?#?#?#?#?#?#? 1,3,1,6"));
    try std.testing.expectEqual(@as(u32, 1), process_line("????.#...#... 4,1,1"));
    try std.testing.expectEqual(@as(u32, 4), process_line("????.######..#####. 1,6,5"));
    try std.testing.expectEqual(@as(u32, 0), process_line("? 2,1"));
    try std.testing.expectEqual(@as(u32, 0), process_line("?? 2,1"));
    try std.testing.expectEqual(@as(u32, 0), process_line("??? 2,1"));
    try std.testing.expectEqual(@as(u32, 1), process_line("???? 2,1"));
    try std.testing.expectEqual(@as(u32, 3), process_line("????? 2,1"));
    try std.testing.expectEqual(@as(u32, 6), process_line("?????? 2,1"));
    try std.testing.expectEqual(@as(u32, 10), process_line("??????? 2,1"));
    try std.testing.expectEqual(@as(u32, 10), process_line("?###???????? 3,2,1"));
}

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 21), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 7670), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input));
}
