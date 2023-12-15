const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn solve_1(inp: []const u8) u32 {
    var parts = std.mem.splitScalar(u8, inp, ',');
    var result: u32 = 0;

    while (parts.next()) |part| {
        result += hash(part);
    }

    return result;
}

fn hash(inp: []const u8) u32 {
    var result: u32 = 0;
    for (inp) |c| {
        result = ((result + c) * 17) % 256;
    }
    return result;
}

pub fn solve_2(inp: []const u8, allocator: Allocator) u32 {
    var parts = std.mem.splitScalar(u8, inp, ',');
    const L = std.ArrayList([]const u8);
    var buckets: [256]L = undefined;
    for (0..256) |i| {
        buckets[i] = L.init(allocator);
    }

    var values = std.StringHashMap(u32).init(allocator);
    defer values.deinit();

    while (parts.next()) |part| {
        const delim_index = std.mem.indexOfAny(u8, part, "=-").?;
        const bucket_id = hash(part[0..delim_index]);
        var bucket = buckets[bucket_id];
        const label = part[0..delim_index];

        switch (part[delim_index]) {
            '=' => {
                const value = std.fmt.parseUnsigned(u32, part[delim_index + 1 ..], 10) catch unreachable;
                if (values.contains(label)) {
                    values.put(label, value) catch unreachable;
                    continue;
                }

                buckets[bucket_id].append(label) catch unreachable;
                values.put(label, value) catch unreachable;
            },
            '-' => {
                if (!values.contains(label)) {
                    continue;
                }

                for (0..bucket.items.len) |i| {
                    if (std.mem.eql(u8, bucket.items[i], label)) {
                        _ = bucket.orderedRemove(i);
                        _ = values.remove(label);
                        buckets[bucket_id] = bucket;
                        break;
                    }
                }
            },
            else => unreachable,
        }
    }

    var result: usize = 0;
    for (buckets, 1..) |bucket, i| {
        for (bucket.items, 1..) |label, j| {
            result += i * j * values.get(label).?;
        }
        bucket.deinit();
    }

    return @truncate(result);
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 1320), solve_1(example_input));
    try std.testing.expectEqual(@as(u32, 505427), solve_1(input));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 145), solve_2(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 243747), solve_2(input, std.testing.allocator));
}
