const std = @import("std");
const Allocator = std.mem.Allocator;

const Coord = struct {
    x: u64,
    y: u64,
};

pub fn solve_1(inp: []const u8, allocator: Allocator) u64 {
    return calculate_distances(inp, 2, allocator);
}

pub fn calculate_distances(inp: []const u8, empty_distance: u32, allocator: Allocator) u64 {
    const width = std.mem.indexOfScalar(u8, inp, '\n').? + 1;
    const height = (inp.len + 2) / width;
    var col_prefix = std.mem.zeroes([140]u32);

    // Correct for missing (\r)\n at end of file
    // Empty columns need to be counted double -> store additional offset for each column
    for (0..width) |col_i| {
        if (inp[col_i] == '\r' or inp[col_i] == '\n') {
            continue;
        }
        var found = false;
        for (0..height) |row_i| {
            const i = col_i + width * row_i;
            if (i < inp.len and inp[i] == '#') {
                found = true;
                break;
            }
        }
        if (found) {
            if (col_i == 0) {
                col_prefix[col_i] = 0;
            } else {
                col_prefix[col_i] = col_prefix[col_i - 1];
            }
        } else {
            if (col_i == 0) {
                col_prefix[col_i] = 1;
            } else {
                col_prefix[col_i] = col_prefix[col_i - 1] + empty_distance - 1;
            }
        }
    }

    // Parse galaxies
    // Empty rows need to be counted double
    var galaxies = std.ArrayList(Coord).init(allocator);
    defer galaxies.deinit();
    var row: u32 = 0;
    var found_galaxy_in_row = false;
    for (0..inp.len) |i| {
        if (inp[i] == '\n') {
            if (!found_galaxy_in_row) {
                row += empty_distance;
            } else {
                row += 1;
            }
            found_galaxy_in_row = false;
            continue;
        }
        if (inp[i] == '#') {
            found_galaxy_in_row = true;
            const x = i % width + col_prefix[i % width];
            const y = row;
            const coord = Coord{ .x = @truncate(x), .y = y };
            galaxies.append(coord) catch unreachable;
        }
    }

    var result: u64 = 0;
    for (galaxies.items, 1..) |this, other_start| {
        for (other_start..galaxies.items.len) |other_i| {
            const other = galaxies.items[other_i];
            result += @max(this.x, other.x) - @min(this.x, other.x);
            result += @max(this.y, other.y) - @min(this.y, other.y);
        }
    }

    return result;
}

pub fn solve_2(inp: []const u8, allocator: Allocator) u64 {
    return calculate_distances(inp, 1000000, allocator);
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u64, 374), solve_1(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u64, 9805264), solve_1(input, std.testing.allocator));
}

test "calculate_distances" {
    try std.testing.expectEqual(@as(u64, 1030), calculate_distances(example_input, 10, std.testing.allocator));
    try std.testing.expectEqual(@as(u64, 8410), calculate_distances(example_input, 100, std.testing.allocator));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u64, 82000210), solve_2(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u64, 779032247216), solve_2(input, std.testing.allocator));
}
