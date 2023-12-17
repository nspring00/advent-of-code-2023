const std = @import("std");
const Allocator = std.mem.Allocator;
const Order = std.math.Order;

const QueueItem = struct {
    pos: i32,
    distance: u32,
    last_direction: u8,
    remaining_steps: u8,
};

const VisitedKey = struct {
    pos: u32,
    last_direction: u8,
    remaining_steps: u8,
};

const RIGHT: u8 = 0;
const DOWN: u8 = 1;
const LEFT: u8 = 2;
const UP: u8 = 3;

pub fn solve_1(inp: []const u8, allocator: Allocator) u32 {
    const width: u32 = @truncate(std.mem.indexOfScalar(u8, inp, '\n').? + 1);
    const content_width = std.mem.indexOfAny(u8, inp, "\r\n").?;
    const height = (inp.len + 2) / width;

    var queue = std.PriorityQueue(QueueItem, void, lessThan).init(allocator, {});
    var visited = std.AutoHashMap(VisitedKey, void).init(allocator);
    defer queue.deinit();
    defer visited.deinit();

    const target: u32 = @truncate((height - 1) * width + content_width - 1);

    queue.add(QueueItem{ .pos = 0, .distance = 0, .last_direction = RIGHT, .remaining_steps = 3 }) catch unreachable;

    const width_i: i32 = @bitCast(width);

    while (queue.removeOrNull()) |item| {
        //std.debug.print("item: {d}\n", .{item.distance});
        if (item.pos < 0 or item.pos >= inp.len) {
            continue;
        }
        const pos_u: u32 = @bitCast(item.pos);
        if (inp[pos_u] == '\r' or inp[pos_u] == '\n') {
            continue;
        }
        //std.debug.print("pos {d}:{c}\n", .{pos_u, inp[pos_u]});
        const distance = if (pos_u == 0) item.distance else item.distance + inp[pos_u] - '0';
        if (pos_u == target) {
            return distance;
        }
        const visited_key = VisitedKey{ .pos = pos_u, .last_direction = item.last_direction, .remaining_steps = item.remaining_steps };
        if (visited.contains(visited_key)) {
            continue;
        }
        visited.put(visited_key, {}) catch unreachable;

        // Move up
        if (item.last_direction != DOWN and (item.last_direction != UP or item.remaining_steps > 0)) {
            const remaining_steps = if (item.last_direction == UP) item.remaining_steps - 1 else 2;
            queue.add(QueueItem{ .pos = item.pos - width_i, .distance = distance, .last_direction = UP, .remaining_steps = remaining_steps }) catch unreachable;
        }
        // Move down
        if (item.last_direction != UP and (item.last_direction != DOWN or item.remaining_steps > 0)) {
            const remaining_steps = if (item.last_direction == DOWN) item.remaining_steps - 1 else 2;
            queue.add(QueueItem{ .pos = item.pos + width_i, .distance = distance, .last_direction = DOWN, .remaining_steps = remaining_steps }) catch unreachable;
        }
        // Move left
        if (item.last_direction != RIGHT and (item.last_direction != LEFT or item.remaining_steps > 0)) {
            const remaining_steps = if (item.last_direction == LEFT) item.remaining_steps - 1 else 2;
            queue.add(QueueItem{ .pos = item.pos - 1, .distance = distance, .last_direction = LEFT, .remaining_steps = remaining_steps }) catch unreachable;
        }
        // Move right
        if (item.last_direction != LEFT and (item.last_direction != RIGHT or item.remaining_steps > 0)) {
            const remaining_steps = if (item.last_direction == RIGHT) item.remaining_steps - 1 else 2;
            queue.add(QueueItem{ .pos = item.pos + 1, .distance = distance, .last_direction = RIGHT, .remaining_steps = remaining_steps }) catch unreachable;
        }
    }

    return 0;
}

fn lessThan(context: void, a: QueueItem, b: QueueItem) Order {
    _ = context;
    return std.math.order(a.distance, b.distance);
}

pub fn solve_2(inp: []const u8) u32 {
    _ = inp;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 102), solve_1(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 843), solve_1(input, std.testing.allocator));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input));
}
