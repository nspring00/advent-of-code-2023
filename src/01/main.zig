const std = @import("std");

pub fn solve_1(inp: []const u8) u32 {
    var result: u32 = 0;
    var first_digit: u8 = 0;
    var last_digit: u8 = 0;

    for (inp) |c| {
        if (c >= '0' and c <= '9') {
            last_digit = c - '0';
            if (first_digit == 0) {
                first_digit = last_digit;
            }
        } else if (c == '\n') {
            result += first_digit * 10 + last_digit;
            first_digit = 0;
            last_digit = 0;
        }
    }

    // Process last line
    result += first_digit * 10 + last_digit;

    return result;
}
const num_strings = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn solve_2(inp: []const u8) u32 {
    var result: u32 = 0;
    var first_digit: u8 = 0;
    var last_digit: u8 = 0;

    var i: usize = 0;
    while (i < inp.len) : (i += 1) {
        const c = inp[i];
        if (c >= '0' and c <= '9') {
            last_digit = c - '0';
            if (first_digit == 0) {
                first_digit = last_digit;
            }
        } else if (c == '\n') {
            result += first_digit * 10 + last_digit;
            first_digit = 0;
            last_digit = 0;
        } else {
            inline for (num_strings, 1..) |s, j| {
                if (i + s.len - 1 < inp.len and std.mem.eql(u8, s, inp[i .. i + s.len])) {
                    last_digit = j;
                    if (first_digit == 0) {
                        first_digit = last_digit;
                    }
                    i += s.len - 1;
                    break;
                }
            }
        }
    }

    // Process last line
    result += first_digit * 10 + last_digit;

    return result;
}

const example_input_1 = @embedFile("input-example-1.txt");
const example_input_2 = @embedFile("input-example-2.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 142), solve_1(example_input_1));
    try std.testing.expectEqual(@as(u32, 55029), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 281), solve_2(example_input_2));
    try std.testing.expectEqual(@as(u32, 55680), solve_2(input));
}
