const std = @import("std");
const Allocator = std.mem.Allocator;
const day_01 = @import("01/main.zig");
const day_02 = @import("02/main.zig");
const day_03 = @import("03/main.zig");
const day_04 = @import("04/main.zig");
const day_05 = @import("05/main.zig");
const day_06 = @import("06/main.zig");
const day_07 = @import("07/main.zig");
const day_08 = @import("08/main.zig");
const day_09 = @import("09/main.zig");
const day_10 = @import("10/main.zig");
const day_11 = @import("11/main.zig");
const day_12 = @import("12/main.zig");
const day_13 = @import("13/main.zig");
const day_14 = @import("14/main.zig");
const day_15 = @import("15/main.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try stdout.print("###################################\n", .{});
    try stdout.print("## Advent of Code 2023 - Ziglang ##\n", .{});
    try stdout.print("###################################\n\n", .{});

    var total_ms: u64 = 0;
    for (1..16) |day| {
        total_ms += try run_day(day, allocator);
    }

    try stdout.print("Total time: {d} ms", .{total_ms});
}

const Solution = struct {
    part_1: u64,
    part_1_time: u64,
    part_2: u64,
    part_2_time: u64,
};

fn run_day(day: usize, allocator: Allocator) !u64 {
    const stdout = std.io.getStdOut().writer();
    const solution = solve_day(day, allocator);
    try stdout.print("Day {d}:\n  Part 1: {d} ({d} ms)\n  Part 2: {d} ({d} ms)\n\n", .{ day, solution.part_1, solution.part_1_time, solution.part_2, solution.part_2_time });
    return solution.part_1_time + solution.part_2_time;
}

fn solve_day(day: usize, allocator: Allocator) Solution {
    const start_1 = std.time.milliTimestamp();
    const part_1 = switch (day) {
        1 => day_01.solve_1(input_01),
        2 => day_02.solve_1(input_02),
        3 => day_03.solve_1(input_03),
        4 => day_04.solve_1(input_04),
        5 => day_05.solve_1(input_05),
        6 => day_06.solve_1(input_06),
        7 => day_07.solve_1(input_07, allocator),
        8 => day_08.solve_1(input_08, allocator),
        9 => day_09.solve_1(input_09),
        10 => day_10.solve_1(input_10),
        11 => day_11.solve_1(input_11, allocator),
        12 => day_12.solve_1(input_12),
        13 => day_13.solve_1(input_13),
        14 => day_14.solve_1(input_14),
        15 => day_15.solve_1(input_15),
        else => @panic("Day not implemented"),
    };
    const end_1 = std.time.milliTimestamp();
    const start_2 = std.time.milliTimestamp();
    const part_2 = switch (day) {
        1 => day_01.solve_2(input_01),
        2 => day_02.solve_2(input_02),
        3 => day_03.solve_2(input_03),
        4 => day_04.solve_2(input_04),
        5 => day_05.solve_2(input_05, allocator),
        6 => day_06.solve_2(input_06),
        7 => day_07.solve_2(input_07, allocator),
        8 => day_08.solve_2(input_08, allocator),
        9 => day_09.solve_2(input_09),
        10 => day_10.solve_2(input_10),
        11 => day_11.solve_2(input_11, allocator),
        12 => day_12.solve_2(input_12),
        13 => day_13.solve_2(input_13),
        14 => day_14.solve_2(input_14, allocator),
        15 => day_15.solve_2(input_15, allocator),
        else => @panic("Day not implemented"),
    };
    const end_2 = std.time.milliTimestamp();

    return .{
        .part_1 = part_1,
        .part_1_time = @bitCast(end_1 - start_1),
        .part_2 = part_2,
        .part_2_time = @bitCast(end_2 - start_2),
    };
}

const input_01 = @embedFile("01/input.txt");
const input_02 = @embedFile("02/input.txt");
const input_03 = @embedFile("03/input.txt");
const input_04 = @embedFile("04/input.txt");
const input_05 = @embedFile("05/input.txt");
const input_06 = @embedFile("06/input.txt");
const input_07 = @embedFile("07/input.txt");
const input_08 = @embedFile("08/input.txt");
const input_09 = @embedFile("09/input.txt");
const input_10 = @embedFile("10/input.txt");
const input_11 = @embedFile("11/input.txt");
const input_12 = @embedFile("12/input.txt");
const input_13 = @embedFile("13/input.txt");
const input_14 = @embedFile("14/input.txt");
const input_15 = @embedFile("15/input.txt");
