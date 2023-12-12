const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;

pub fn solve_1(inp: []const u8) u64 {
    var result: u64 = 0;
    var lines = iter_lines(inp);
    while (lines.next()) |line| {
        result += process_line(line);
    }
    return result;
}

fn process_line(line: []const u8) u64 {
    const str_end = std.mem.indexOfScalar(u8, line, ' ').?;
    const str = line[0..str_end];

    // Parse groups
    var group_iter = std.mem.splitScalar(u8, line[str_end + 1 ..], ',');
    var groups = std.mem.zeroes([6]u8);
    var i: usize = 0;
    while (group_iter.next()) |group| {
        groups[i] = std.fmt.parseInt(u8, group, 10) catch unreachable;
        i += 1;
    }

    // Dynamic programming cache
    var cache = std.mem.zeroes([21 * 7]u64);
    return group_permutations(str, groups[0..i], &cache, 7);
}

fn group_permutations(line: []const u8, groups: []u8, cache: []u64, group_count: u8) u64 {
    // Cache lookup before optional . skip
    // Always cache result + 1 to avoid 0 being a valid cache value
    const cache_key_1 = line.len * group_count + groups.len;
    if (cache[cache_key_1] > 0) {
        return cache[cache_key_1] - 1;
    }

    // Skip all . prefixes
    const next_hash = std.mem.indexOfAny(u8, line, "#?");
    if (next_hash == null) {
        if (groups.len == 0) {
            return 1;
        } else {
            return 0;
        }
    }

    const str = line[next_hash.?..];

    // Cache lookup after optional . skip
    const cache_key_2 = str.len * group_count + groups.len;
    if (cache[cache_key_2] > 0) {
        return cache[cache_key_2] - 1;
    }

    // Recurse
    var result: u64 = undefined;
    if (str[0] == '#') {
        // Case first char is #
        result = group_permutations_hash(str, groups, cache, group_count);
    } else {
        // Case first char is ?
        result = group_permutations_hash(str, groups, cache, group_count) + group_permutations(str[1..], groups, cache, group_count);
    }

    // Cache result (including for optional . skip)
    // Always cache result + 1 to avoid 0 being a valid cache value
    var i: usize = cache_key_2;
    while (i <= cache_key_1) : (i += group_count) {
        cache[i] = result + 1;
    }
    return result;
}

fn group_permutations_hash(str: []const u8, groups: []u8, cache: []u64, group_count: u8) u64 {
    if (str[0] == '.') {
        @panic("This should not happen");
    }

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
    return group_permutations(str[group_len + 1 ..], groups[1..], cache, group_count);
}

pub fn solve_2(inp: []const u8) u64 {
    var result: u64 = 0;
    var lines = iter_lines(inp);
    while (lines.next()) |line| {
        result += process_line_2(line);
    }
    return result;
}

fn process_line_2(line: []const u8) u64 {
    const max_str_len = 20 * 5 + 4;
    const max_groups_len = 30;

    const str_end = std.mem.indexOfScalar(u8, line, ' ').?;
    const str_fold = line[0..str_end];

    // Unfold string 5 times and add ? between
    var str = std.mem.zeroes([max_str_len]u8);
    var str_len: usize = 0;
    for (0..5) |i| {
        if (i != 0) {
            str[str_len] = '?';
            str_len += 1;
        }
        std.mem.copy(u8, str[str_len..], str_fold);
        str_len += str_fold.len;
    }
    var str_slice = (&str[0..str_len]).*;

    // Parse groups
    var group_iter = std.mem.splitScalar(u8, line[str_end + 1 ..], ',');
    var groups = std.mem.zeroes([max_groups_len]u8);
    var i: usize = 0;
    while (group_iter.next()) |group| {
        groups[i] = std.fmt.parseInt(u8, group, 10) catch unreachable;
        i += 1;
    }

    // Unfold groups 5 times
    for (1..5) |j| {
        for (0..i) |k| {
            groups[i * j + k] = groups[k];
        }
    }

    // Dynamic programming cache
    var cache = std.mem.zeroes([(max_str_len + 1) * (max_groups_len + 1)]u64);
    return group_permutations(str_slice, groups[0 .. 5 * i], &cache, max_groups_len + 1);
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "process_line" {
    try std.testing.expectEqual(@as(u64, 1), process_line("???.### 1,1,3"));
    try std.testing.expectEqual(@as(u64, 4), process_line(".??..??...?##. 1,1,3"));
    try std.testing.expectEqual(@as(u64, 1), process_line("?#?#?#?#?#?#?#? 1,3,1,6"));
    try std.testing.expectEqual(@as(u64, 1), process_line("????.#...#... 4,1,1"));
    try std.testing.expectEqual(@as(u64, 4), process_line("????.######..#####. 1,6,5"));
    try std.testing.expectEqual(@as(u64, 10), process_line("?###???????? 3,2,1"));
}

test "process_line_2" {
    try std.testing.expectEqual(@as(u64, 1), process_line_2("???.### 1,1,3"));
    try std.testing.expectEqual(@as(u64, 16384), process_line_2(".??..??...?##. 1,1,3"));
    try std.testing.expectEqual(@as(u64, 1), process_line_2("?#?#?#?#?#?#?#? 1,3,1,6"));
    try std.testing.expectEqual(@as(u64, 16), process_line_2("????.#...#... 4,1,1"));
    try std.testing.expectEqual(@as(u64, 2500), process_line_2("????.######..#####. 1,6,5"));
    try std.testing.expectEqual(@as(u64, 506250), process_line_2("?###???????? 3,2,1"));
}

test "solve_1" {
    try std.testing.expectEqual(@as(u64, 21), solve_1(example_input));
    try std.testing.expectEqual(@as(u64, 7670), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u64, 525152), solve_2(example_input));
    try std.testing.expectEqual(@as(u64, 157383940585037), solve_2(input));
}
