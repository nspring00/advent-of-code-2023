const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn solve_1(inp: []const u8) u32 {
    const width = (std.mem.indexOfScalar(u8, inp, '\n') orelse unreachable) + 1;
    var result: u32 = 0;

    const no_number = std.math.maxInt(usize);
    var left: usize = no_number;

    for (inp, 0..) |c, i| {
        if (left == no_number and is_digit(c)) {
            left = i;
            continue;
        }

        if (left == no_number or is_digit(c)) {
            continue;
        }

        const number = std.fmt.parseInt(u32, inp[left..i], 10) catch unreachable;

        var found_symbol = false;
        const min = if (left == 0) 0 else left - 1;
        for (min..i + 1) |j| {
            if (width <= j and j - width < inp.len and is_symbol(inp[j - width])) {
                found_symbol = true;
                break;
            }
            if (j + width < inp.len and is_symbol(inp[j + width])) {
                found_symbol = true;
                break;
            }
        }
        if (left > 0 and is_symbol(inp[left - 1])) {
            found_symbol = true;
        }
        if (i < inp.len and is_symbol(inp[i])) {
            found_symbol = true;
        }

        if (found_symbol) {
            result += number;
        }

        left = no_number;
    }

    return result;
}

fn is_digit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn is_symbol(c: u8) bool {
    return (c < '0' or c > '9') and c != '.' and c != '\r' and c != '\n';
}

pub fn solve_2(inp: []const u8) u32 {
    _ = inp;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 4361), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 532428), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input));
}
