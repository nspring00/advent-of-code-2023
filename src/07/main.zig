const std = @import("std");
const utils = @import("../utils.zig");
const iter_lines = utils.iter_lines;
const Allocator = std.mem.Allocator;

const Hand = struct {
    cards: [5]u8,
    bid: u32,
    value: u32,
};

pub fn solve_1(inp: []const u8, allocator: Allocator) u32 {
    var lines = iter_lines(inp);
    var hands_list = std.ArrayList(Hand).init(allocator);

    while (lines.next()) |line| {
        hands_list.append(parse_hand_1(line)) catch unreachable;
    }

    const hands = hands_list.toOwnedSlice() catch unreachable;
    defer allocator.free(hands);

    std.mem.sort(Hand, hands, {}, cmp_hands);

    var result: u32 = 0;
    for (hands, 1..) |hand, rank| {
        const rank_int: u32 = @truncate(rank);
        result += rank_int * hand.bid;
    }

    return result;
}

fn cmp_hands(context: void, a: Hand, b: Hand) bool {
    _ = context;
    if (a.value < b.value) {
        return true;
    } else if (a.value > b.value) {
        return false;
    }

    for (0..5) |i| {
        if (a.cards[i] < b.cards[i]) {
            return true;
        } else if (a.cards[i] > b.cards[i]) {
            return false;
        }
    }

    @panic("hands are equal");
}

fn parse_hand_1(line: []const u8) Hand {
    var cards: [5]u8 = undefined;
    for (0..5) |i| {
        if (line[i] >= '1' and line[i] <= '9') {
            cards[i] = line[i] - '0';
        } else if (line[i] == 'T') {
            cards[i] = 10;
        } else if (line[i] == 'J') {
            cards[i] = 11;
        } else if (line[i] == 'Q') {
            cards[i] = 12;
        } else if (line[i] == 'K') {
            cards[i] = 13;
        } else if (line[i] == 'A') {
            cards[i] = 14;
        } else {
            @panic("invalid card");
        }
    }

    const bid = std.fmt.parseInt(u32, line[6..], 10) catch unreachable;

    return Hand{
        .cards = cards,
        .bid = bid,
        .value = calculate_hand_value_1(cards),
    };
}

fn calculate_hand_value_1(cards: [5]u8) u32 {
    var distinct_values = std.mem.zeroes([5]u8);
    var distinct_values_count: u8 = 0;
    cardLoop: for (cards) |card| {
        for (distinct_values[0..distinct_values_count]) |distinct_value| {
            if (distinct_value == card) {
                continue :cardLoop;
            }
        }
        distinct_values[distinct_values_count] = card;
        distinct_values_count += 1;
    }

    if (distinct_values_count == 5) {
        // High card
        return 0;
    } else if (distinct_values_count == 4) {
        // One pair
        return 1;
    } else if (distinct_values_count == 3) {
        // Two pair or three of a kind
        var is_three_of_a_kind = false;
        for (distinct_values[0..distinct_values_count]) |distinct_value| {
            var count: u8 = 0;
            for (cards) |card| {
                if (card == distinct_value) {
                    count += 1;
                }
            }
            if (count == 3) {
                is_three_of_a_kind = true;
                break;
            }
        }

        if (is_three_of_a_kind) {
            return 3;
        } else {
            return 2;
        }
    } else if (distinct_values_count == 2) {
        // Full house or four of a kind
        var is_four_of_a_kind = false;
        for (distinct_values[0..distinct_values_count]) |distinct_value| {
            var count: u8 = 0;
            for (cards) |card| {
                if (card == distinct_value) {
                    count += 1;
                }
            }
            if (count == 4) {
                is_four_of_a_kind = true;
                break;
            }
        }

        if (is_four_of_a_kind) {
            return 5;
        } else {
            return 4;
        }
    }

    // 5 of a kind
    return 6;
}

fn parse_hand_2(line: []const u8) Hand {
    var cards: [5]u8 = undefined;
    for (0..5) |i| {
        if (line[i] >= '1' and line[i] <= '9') {
            cards[i] = line[i] - '0';
        } else if (line[i] == 'T') {
            cards[i] = 10;
        } else if (line[i] == 'J') {
            cards[i] = 0; // Joker is not lowest card
        } else if (line[i] == 'Q') {
            cards[i] = 12;
        } else if (line[i] == 'K') {
            cards[i] = 13;
        } else if (line[i] == 'A') {
            cards[i] = 14;
        } else {
            @panic("invalid card");
        }
    }

    const bid = std.fmt.parseInt(u32, line[6..], 10) catch unreachable;

    return Hand{
        .cards = cards,
        .bid = bid,
        .value = calculate_hand_value_2(cards),
    };
}

fn calculate_hand_value_2(cards: [5]u8) u32 {
    var joker_count: u8 = 0;
    var distinct_values = std.mem.zeroes([5]u8);
    var distinct_values_count: u8 = 0;
    cardLoop: for (cards) |card| {
        if (card == 0) {
            joker_count += 1;
            continue;
        }
        for (distinct_values[0..distinct_values_count]) |distinct_value| {
            if (distinct_value == card) {
                continue :cardLoop;
            }
        }
        distinct_values[distinct_values_count] = card;
        distinct_values_count += 1;
    }

    if (joker_count == 0) {
        return calculate_hand_value_1(cards);
    }

    // Count the card with the most occurrences
    var max_count: u8 = 0;
    for (cards) |value| {
        if (value == 0) {
            continue;
        }
        var count: u8 = 0;
        for (cards) |card| {
            if (card == value) {
                count += 1;
            }
        }
        if (count > max_count) {
            max_count = count;
        }
    }

    if (max_count + joker_count == 3 and distinct_values_count == 2) {
        // Full house
        return 4;
    }

    return switch (max_count + joker_count) {
        5 => 6, // 5 of a kind
        4 => 5, // 4 of a kind
        3 => 3, // 3 of a kind
        2 => 1, // 2 of a kind
        else => unreachable,
    };
}

pub fn solve_2(inp: []const u8, allocator: Allocator) u32 {
    var lines = iter_lines(inp);
    var hands_list = std.ArrayList(Hand).init(allocator);

    while (lines.next()) |line| {
        hands_list.append(parse_hand_2(line)) catch unreachable;
    }

    const hands = hands_list.toOwnedSlice() catch unreachable;
    defer allocator.free(hands);

    std.mem.sort(Hand, hands, {}, cmp_hands);

    var result: u32 = 0;
    for (hands, 1..) |hand, rank| {
        const rank_int: u32 = @truncate(rank);
        result += rank_int * hand.bid;
    }

    return result;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "calculate_hand_value_1" {
    try std.testing.expectEqual(@as(u32, 0), calculate_hand_value_1([_]u8{ 2, 3, 7, 5, 6 }));
    try std.testing.expectEqual(@as(u32, 1), calculate_hand_value_1([_]u8{ 3, 2, 10, 3, 13 }));
    try std.testing.expectEqual(@as(u32, 2), calculate_hand_value_1([_]u8{ 10, 5, 10, 11, 5 }));
    try std.testing.expectEqual(@as(u32, 3), calculate_hand_value_1([_]u8{ 10, 5, 5, 11, 5 }));
    try std.testing.expectEqual(@as(u32, 4), calculate_hand_value_1([_]u8{ 10, 5, 10, 10, 5 }));
    try std.testing.expectEqual(@as(u32, 5), calculate_hand_value_1([_]u8{ 10, 10, 10, 5, 10 }));
    try std.testing.expectEqual(@as(u32, 6), calculate_hand_value_1([_]u8{ 10, 10, 10, 10, 10 }));
}

test "calculate_hand_value_2" {
    // Same output if no jokers
    try std.testing.expectEqual(@as(u32, 0), calculate_hand_value_2([_]u8{ 2, 3, 7, 5, 6 }));
    try std.testing.expectEqual(@as(u32, 1), calculate_hand_value_2([_]u8{ 3, 2, 10, 3, 13 }));
    try std.testing.expectEqual(@as(u32, 2), calculate_hand_value_2([_]u8{ 10, 5, 10, 11, 5 }));
    try std.testing.expectEqual(@as(u32, 3), calculate_hand_value_2([_]u8{ 10, 5, 5, 11, 5 }));
    try std.testing.expectEqual(@as(u32, 4), calculate_hand_value_2([_]u8{ 10, 5, 10, 10, 5 }));
    try std.testing.expectEqual(@as(u32, 5), calculate_hand_value_2([_]u8{ 10, 10, 10, 5, 10 }));
    try std.testing.expectEqual(@as(u32, 6), calculate_hand_value_2([_]u8{ 10, 10, 10, 10, 10 }));

    // Using jokers
    try std.testing.expectEqual(@as(u32, 1), calculate_hand_value_2([_]u8{ 2, 3, 0, 5, 6 }));
    try std.testing.expectEqual(@as(u32, 3), calculate_hand_value_2([_]u8{ 2, 3, 0, 5, 0 }));
    try std.testing.expectEqual(@as(u32, 5), calculate_hand_value_2([_]u8{ 2, 0, 0, 5, 0 }));
    try std.testing.expectEqual(@as(u32, 5), calculate_hand_value_2([_]u8{ 2, 2, 0, 5, 0 }));
    try std.testing.expectEqual(@as(u32, 6), calculate_hand_value_2([_]u8{ 2, 2, 0, 0, 0 }));
    try std.testing.expectEqual(@as(u32, 6), calculate_hand_value_2([_]u8{ 2, 2, 2, 0, 0 }));
    try std.testing.expectEqual(@as(u32, 6), calculate_hand_value_2([_]u8{ 2, 2, 2, 2, 0 }));
    try std.testing.expectEqual(@as(u32, 6), calculate_hand_value_2([_]u8{ 0, 0, 2, 0, 0 }));
    try std.testing.expectEqual(@as(u32, 6), calculate_hand_value_2([_]u8{ 0, 0, 0, 0, 0 }));
    try std.testing.expectEqual(@as(u32, 4), calculate_hand_value_2([_]u8{ 5, 5, 0, 3, 3 }));
}

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 6440), solve_1(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 251029473), solve_1(input, std.testing.allocator));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 5905), solve_2(example_input, std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 251003917), solve_2(input, std.testing.allocator));
}
