const std = @import("std");

pub fn solve_1(inp: []const u8) u32 {
    const delim = if (std.mem.indexOfScalar(u8, inp, '\r') != null) "\r\n\r\n" else "\n\n";
    var blocks = std.mem.split(u8, inp, delim);

    var result: u32 = 0;
    while (blocks.next()) |block| {
        const horizontal = mirrors_horizontal(block);
        if (horizontal != 0) {
            result += 100 * horizontal;
            continue;
        }

        const vertical = mirrors_vertical(block);
        if (vertical == 0) {
            @panic("found no mirror");
        }
        result += vertical;
    }

    return result;
}

fn mirrors_horizontal(inp: []const u8) u32 {
    const width = std.mem.indexOfScalar(u8, inp, '\n').? + 1;
    const content_width = std.mem.indexOfAny(u8, inp, "\r\n").?;
    const height = (inp.len + 2) / width;

    for (1..height) |r_split| {
        for (0..height) |r_offset| {
            if (r_offset + 1 > r_split or r_split + r_offset >= height) {
                return @truncate(r_split);
            }

            const upper = (r_split - r_offset - 1) * width;
            const lower = (r_split + r_offset) * width;

            if (!std.mem.eql(u8, inp[upper .. upper + content_width], inp[lower .. lower + content_width])) {
                break;
            }
        }
    }

    return 0;
}

fn mirrors_vertical(inp: []const u8) u32 {
    const width = std.mem.indexOfScalar(u8, inp, '\n').? + 1;
    const content_width = std.mem.indexOfAny(u8, inp, "\r\n").?;
    const height = (inp.len + 2) / width;

    for (1..content_width) |c_split| {
        inner: for (0..content_width) |c_offset| {
            if (c_offset + 1 > c_split or c_split + c_offset >= content_width) {
                return @truncate(c_split);
            }

            const left = c_split - c_offset - 1;
            const right = c_split + c_offset;

            for (0..height) |r| {
                const left_idx = r * width + left;
                const right_idx = r * width + right;

                if (inp[left_idx] != inp[right_idx]) {
                    break :inner;
                }
            }
        }
    }

    return 0;
}

pub fn solve_2(inp: []const u8) u32 {
    _ = inp;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 405), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 37561), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input));
}
