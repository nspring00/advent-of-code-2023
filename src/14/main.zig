const std = @import("std");
const Allocator = std.mem.Allocator;

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

pub fn solve_2(inp: []const u8, allocator: Allocator) u32 {
    const width: u8 = @truncate(std.mem.indexOfScalar(u8, inp, '\n').? + 1);
    const content_width: u8 = @truncate(std.mem.indexOfAny(u8, inp, "\r\n").?);
    const height: u8 = @truncate((inp.len + 2) / width);

    var moving = std.mem.zeroes([10_000]bool);
    var rocks = std.mem.zeroes([10_000]bool);
    var inp_i: usize = 0;

    for (inp) |c| {
        switch (c) {
            '\r', '\n' => continue,
            '.' => {},
            '#' => rocks[inp_i] = true,
            'O' => moving[inp_i] = true,
            else => @panic("invalid input"),
        }
        inp_i += 1;
    }

    var lookup = std.AutoHashMap([10_000]bool, u32).init(allocator);
    defer lookup.deinit();

    var cycle: u32 = 0;
    while (true) {
        var key = std.mem.zeroes([10_000]bool);
        std.mem.copyForwards(bool, &key, &moving);

        if (lookup.get(key)) |cycle_start| {
            const cycle_length = cycle - cycle_start;
            const remaining = (1_000_000_000 - cycle) % cycle_length;

            for (0..remaining) |_| {
                run_cycle(&moving, &rocks, content_width, height);
            }

            return calculate_north_load(&moving, content_width, height);
        }

        lookup.put(key, cycle) catch unreachable;
        run_cycle(&moving, &rocks, content_width, height);
        cycle += 1;
    }

    unreachable;
}

fn run_cycle(moving: []bool, rocks: []const bool, width: u8, height: u8) void {
    // Modify moving in-place
    // Move all moving objects up as far as possible
    var offset: usize = 0;
    for (0..width) |j| {
        offset = 0;
        for (0..height) |i| {
            const idx = width * i + j;
            if (rocks[idx]) {
                offset = i + 1;
            } else if (moving[idx]) {
                moving[idx] = false;
                moving[width * offset + j] = true;
                offset += 1;
            }
        }
    }

    // Move all moving objects left as far as possible
    for (0..height) |i| {
        offset = 0;
        for (0..width) |j| {
            const idx = width * i + j;
            if (rocks[idx]) {
                offset = j + 1;
            } else if (moving[idx]) {
                moving[idx] = false;
                moving[width * i + offset] = true;
                offset += 1;
            }
        }
    }

    // Move all moving objects down as far as possible
    for (0..width) |j| {
        offset = height - 1;
        for (0..height) |i_rev| {
            const i = height - 1 - i_rev;
            const idx = width * i + j;
            if (rocks[idx] and i > 0) {
                offset = i - 1;
            } else if (moving[idx]) {
                moving[idx] = false;
                moving[width * offset + j] = true;
                if (offset > 0) {
                    offset -= 1;
                }
            }
        }
    }

    // Move all moving objects right as far as possible
    for (0..height) |i| {
        offset = width - 1;
        for (0..width) |j_rev| {
            const j = width - 1 - j_rev;
            const idx = width * i + j;
            if (rocks[idx] and j > 0) {
                offset = j - 1;
            } else if (moving[idx]) {
                moving[idx] = false;
                moving[width * i + offset] = true;
                if (offset > 0) {
                    offset -= 1;
                }
            }
        }
    }
}

fn calculate_north_load(moving: []bool, width: u8, height: u8) u32 {
    var result: u32 = 0;
    for (0..height) |i| {
        const weight: u32 = @truncate(height - i);
        for (0..width) |j| {
            const idx = width * i + j;
            if (moving[idx]) {
                result += weight;
            }
        }
    }

    return result;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 136), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 113486), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 64), solve_2(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 104409), solve_2(input, std.testing.allocator));
}
