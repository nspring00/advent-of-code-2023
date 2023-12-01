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
        }
        else if (c == '\n') {
            result += first_digit * 10 + last_digit;
            first_digit = 0;
            last_digit = 0;
        }
    }

    // Process last line
    result += first_digit * 10 + last_digit;

    return result;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 142), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 55029), solve_1(input));
}