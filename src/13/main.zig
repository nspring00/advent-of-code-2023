const std = @import("std");

// Note: Found out afterwards that another implementation possibility is to use
// uints as bitvectors for each row/column and then use xor and popcount to find
// the number of differences. Still, it runs in < 2 ms, so I'm not too worried :)
pub fn solve_1(inp: []const u8) u32 {
    return find_mirror(inp, false);
}

fn find_mirror(inp: []const u8, one_diff: bool) u32 {
    const delim = if (std.mem.indexOfScalar(u8, inp, '\r') != null) "\r\n\r\n" else "\n\n";
    var blocks = std.mem.split(u8, inp, delim);

    var result: u32 = 0;
    while (blocks.next()) |block| {
        const horizontal = mirrors_horizontal(block, one_diff);
        if (horizontal != 0) {
            result += 100 * horizontal;
            continue;
        }

        const vertical = mirrors_vertical(block, one_diff);
        if (vertical != 0) {
            result += vertical;
            continue;
        }

        @panic("found no mirror");
    }

    return result;
}

fn mirrors_horizontal(inp: []const u8, one_diff: bool) u32 {
    const width = std.mem.indexOfScalar(u8, inp, '\n').? + 1;
    const content_width = std.mem.indexOfAny(u8, inp, "\r\n").?;
    const height = (inp.len + 2) / width;

    for (1..height) |r_split| {
        var found_diff = false;
        inner: for (0..height) |r_offset| {
            if (r_offset + 1 > r_split or r_split + r_offset >= height) {
                if (one_diff and !found_diff) {
                    break;
                }
                return @truncate(r_split);
            }

            const upper = (r_split - r_offset - 1) * width;
            const lower = (r_split + r_offset) * width;

            if ((!one_diff or found_diff) and !std.mem.eql(u8, inp[upper .. upper + content_width], inp[lower .. lower + content_width])) {
                break;
            }
            if (one_diff) {
                for (0..content_width) |c| {
                    if (inp[upper + c] != inp[lower + c]) {
                        if (found_diff) {
                            break :inner;
                        }
                        found_diff = true;
                    }
                }
            }
        }
    }

    return 0;
}

fn mirrors_vertical(inp: []const u8, one_diff: bool) u32 {
    const width = std.mem.indexOfScalar(u8, inp, '\n').? + 1;
    const content_width = std.mem.indexOfAny(u8, inp, "\r\n").?;
    const height = (inp.len + 2) / width;

    for (1..content_width) |c_split| {
        var found_diff = false;
        inner: for (0..content_width) |c_offset| {
            if (c_offset + 1 > c_split or c_split + c_offset >= content_width) {
                if (one_diff and !found_diff) {
                    break;
                }
                return @truncate(c_split);
            }

            const left = c_split - c_offset - 1;
            const right = c_split + c_offset;

            for (0..height) |r| {
                const left_idx = r * width + left;
                const right_idx = r * width + right;

                if ((!one_diff or found_diff) and inp[left_idx] != inp[right_idx]) {
                    break :inner;
                } else if (one_diff and inp[left_idx] != inp[right_idx]) {
                    found_diff = true;
                }
            }
        }
    }

    return 0;
}

pub fn solve_2(inp: []const u8) u32 {
    return find_mirror(inp, true);
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 405), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 37561), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 400), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 31108), solve_2(input));
}
