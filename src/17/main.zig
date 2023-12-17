const std = @import("std");
const Allocator = std.mem.Allocator;
const Order = std.math.Order;

const QueueItem = struct {
    pos: i32,
    distance: u32,
    last_direction: u8,
    steps_to_go: u8,
    remaining_steps: u8,
};

const VisitedKey = struct {
    pos: u32,
    last_direction: u8,
    steps_to_go: u8,
    remaining_steps: u8,
};

const RIGHT: u8 = 0;
const DOWN: u8 = 1;
const LEFT: u8 = 2;
const UP: u8 = 3;

pub fn solve_1(inp: []const u8, allocator: Allocator) u32 {
    return shortest_path(inp, allocator, 1, 3);
}

pub fn shortest_path(inp: []const u8, allocator: Allocator, min_dist: u8, max_dist: u8) u32 {
    const width: u32 = @truncate(std.mem.indexOfScalar(u8, inp, '\n').? + 1);
    const content_width = std.mem.indexOfAny(u8, inp, "\r\n").?;
    const height = (inp.len + 2) / width;

    var queue = std.PriorityQueue(QueueItem, void, lessThan).init(allocator, {});
    var visited = std.AutoHashMap(VisitedKey, void).init(allocator);
    defer queue.deinit();
    defer visited.deinit();

    const target: u32 = @truncate((height - 1) * width + content_width - 1);

    queue.add(QueueItem{ .pos = 0, .distance = 0, .last_direction = 255, .steps_to_go = 0, .remaining_steps = max_dist }) catch unreachable;

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
        const distance = if (pos_u == 0) item.distance else item.distance + inp[pos_u] - '0';
        // std.debug.print("pos {d}:{c} distance {d}\n", .{pos_u, inp[pos_u], distance});
        if (pos_u == target and item.steps_to_go == 0) {
            return distance;
        }
        const visited_key = VisitedKey{ .pos = pos_u, .last_direction = item.last_direction, .steps_to_go = item.steps_to_go, .remaining_steps = item.remaining_steps };
        if (visited.contains(visited_key)) {
            continue;
        }
        visited.put(visited_key, {}) catch unreachable;

        // Move up
        if (item.last_direction != DOWN and (item.last_direction != UP or item.remaining_steps > 0) and (item.last_direction == UP or item.steps_to_go == 0)) {
            const remaining_steps = if (item.last_direction == UP) item.remaining_steps - 1 else max_dist - 1;
            const steps_to_go = if (item.last_direction == UP) (if (item.steps_to_go == 0) 0 else item.steps_to_go - 1) else min_dist - 1;
            queue.add(QueueItem{ .pos = item.pos - width_i, .distance = distance, .last_direction = UP, .steps_to_go = steps_to_go, .remaining_steps = remaining_steps }) catch unreachable;
        }
        // Move down
        if (item.last_direction != UP and (item.last_direction != DOWN or item.remaining_steps > 0) and (item.last_direction == DOWN or item.steps_to_go == 0)) {
            const remaining_steps = if (item.last_direction == DOWN) item.remaining_steps - 1 else max_dist - 1;
            const steps_to_go = if (item.last_direction == DOWN) (if (item.steps_to_go == 0) 0 else item.steps_to_go - 1) else min_dist - 1;
            queue.add(QueueItem{ .pos = item.pos + width_i, .distance = distance, .last_direction = DOWN, .steps_to_go = steps_to_go, .remaining_steps = remaining_steps }) catch unreachable;
        }
        // Move left
        if (item.last_direction != RIGHT and (item.last_direction != LEFT or item.remaining_steps > 0) and (item.last_direction == LEFT or item.steps_to_go == 0)) {
            const remaining_steps = if (item.last_direction == LEFT) item.remaining_steps - 1 else max_dist - 1;
            const steps_to_go = if (item.last_direction == LEFT) (if (item.steps_to_go == 0) 0 else item.steps_to_go - 1) else min_dist - 1;
            queue.add(QueueItem{ .pos = item.pos - 1, .distance = distance, .last_direction = LEFT, .steps_to_go = steps_to_go, .remaining_steps = remaining_steps }) catch unreachable;
        }
        // Move right
        if (item.last_direction != LEFT and (item.last_direction != RIGHT or item.remaining_steps > 0) and (item.last_direction == RIGHT or item.steps_to_go == 0)) {
            const remaining_steps = if (item.last_direction == RIGHT) item.remaining_steps - 1 else max_dist - 1;
            const steps_to_go = if (item.last_direction == RIGHT) (if (item.steps_to_go == 0) 0 else item.steps_to_go - 1) else min_dist - 1;
            queue.add(QueueItem{ .pos = item.pos + 1, .distance = distance, .last_direction = RIGHT, .steps_to_go = steps_to_go, .remaining_steps = remaining_steps }) catch unreachable;
        }
    }

    unreachable;
}

fn lessThan(context: void, a: QueueItem, b: QueueItem) Order {
    _ = context;
    return std.math.order(a.distance, b.distance);
}

pub fn solve_2(inp: []const u8, allocator: Allocator) u32 {
    return shortest_path(inp, allocator, 4, 10);
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 102), solve_1(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 843), solve_1(input, std.testing.allocator));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 94), solve_2(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 71), solve_2("111111111111\n999999999991\n999999999991\n999999999991\n999999999991", std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 1017), solve_2(input, std.testing.allocator));
}
