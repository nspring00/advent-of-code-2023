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
    const width = (std.mem.indexOfScalar(u8, inp, '\n') orelse unreachable) + 1;
    var result: u32 = 0;

    var i: usize = 0;
    while (std.mem.indexOfPos(u8, inp, i, "*")) |idx| {
        result += gear_nr(inp, idx, width);
        i = idx + 1;
    }

    return result;
}

fn gear_nr(inp: []const u8, idx: usize, width: usize) u32 {
    var right1: usize = 0;
    var right2: usize = 0;
    var number1: u32 = 0;
    var number2: u32 = 0;

    for (idx - 1..idx + 2) |i| {
        if (width <= i and i - width >= right1 and is_digit(inp[i - width])) {
            const left = get_bound_left(inp, i - width);
            right1 = get_bound_right(inp, i - width);
            const nr = std.fmt.parseInt(u32, inp[left..right1], 10) catch unreachable;
            if (number1 == 0) {
                number1 = nr;
            } else if (number2 == 0) {
                number2 = nr;
            } else {
                return 0;
            }
        }

        if (i + width < inp.len and i + width >= right2 and is_digit(inp[i + width])) {
            const left = get_bound_left(inp, i + width);
            right2 = get_bound_right(inp, i + width);
            const nr = std.fmt.parseInt(u32, inp[left..right2], 10) catch unreachable;
            if (number1 == 0) {
                number1 = nr;
            } else if (number2 == 0) {
                number2 = nr;
            } else {
                return 0;
            }
        }
    }

    if (idx > 0 and is_digit(inp[idx - 1])) {
        const left = get_bound_left(inp, idx - 1);
        const nr = std.fmt.parseInt(u32, inp[left..idx], 10) catch unreachable;
        if (number1 == 0) {
            number1 = nr;
        } else if (number2 == 0) {
            number2 = nr;
        } else {
            return 0;
        }
    }

    if (idx + 1 < inp.len and is_digit(inp[idx + 1])) {
        const right = get_bound_right(inp, idx + 1);
        const nr = std.fmt.parseInt(u32, inp[idx + 1 .. right], 10) catch unreachable;
        if (number1 == 0) {
            number1 = nr;
        } else if (number2 == 0) {
            number2 = nr;
        } else {
            return 0;
        }
    }

    if (number1 == 0 or number2 == 0) {
        return 0;
    }
    return number1 * number2;
}

fn get_bound_left(inp: []const u8, i: usize) usize {
    var left = i;
    while (left > 0 and is_digit(inp[left - 1])) {
        left -= 1;
    }
    return left;
}

fn get_bound_right(inp: []const u8, i: usize) usize {
    var right = i;
    while (right < inp.len and is_digit(inp[right])) {
        right += 1;
    }
    return right;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 4361), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 532428), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 467835), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 84051670), solve_2(input));
}
