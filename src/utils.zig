const std = @import("std");

pub fn iter_lines(buffer: []const u8) std.mem.SplitIterator(u8, .sequence) {
    const delimiter = if (std.mem.indexOfScalar(u8, buffer, '\r') != null) "\r\n" else "\n";
    return .{
        .index = 0,
        .buffer = buffer,
        .delimiter = delimiter,
    };
}

test "line_iter_unix" {
    const unix_input = "hello\nworld\n";
    var unix_lines = std.mem.split(u8, unix_input, "\n");

    var unix_iter = iter_lines(unix_input);

    while (unix_lines.next()) |line| {
        const next = unix_iter.next();
        try std.testing.expect(next != null);
        try std.testing.expect(std.mem.eql(u8, line, next orelse unreachable));
    }
}

test "line_iter_windows" {
    const windows_input = "hello\r\nworld\r\n";
    var windows_lines = std.mem.split(u8, windows_input, "\r\n");

    var windows_iter = iter_lines(windows_input);

    while (windows_lines.next()) |line| {
        const next = windows_iter.next();
        try std.testing.expect(next != null);
        try std.testing.expect(std.mem.eql(u8, line, next orelse unreachable));
    }
}

/// Returns the least common multiple (LCM) of two unsigned integers (a and b) which are not both zero.
/// For example, the LCM of 2 and 3 is 6, and the LCM of 6 and 8 is 24.
pub fn lcm(a: anytype, b: anytype) @TypeOf(a, b) {
    return (a / std.math.gcd(a, b)) * b;
}

test "lcm" {
    try std.testing.expect(lcm(2, 3) == 6);
    try std.testing.expect(lcm(3, 5) == 15);
    try std.testing.expect(lcm(4, 6) == 12);
    try std.testing.expect(lcm(5, 7) == 35);
    try std.testing.expect(lcm(6, 8) == 24);
    try std.testing.expect(lcm(7, 9) == 63);
    try std.testing.expect(lcm(8, 10) == 40);
    try std.testing.expect(lcm(9, 11) == 99);
    try std.testing.expect(lcm(10, 12) == 60);
    try std.testing.expect(lcm(11, 13) == 143);
    try std.testing.expect(lcm(12, 14) == 84);
    try std.testing.expect(lcm(13, 15) == 195);
    try std.testing.expect(lcm(14, 16) == 112);
    try std.testing.expect(lcm(15, 17) == 255);
    try std.testing.expect(lcm(16, 18) == 144);
    try std.testing.expect(lcm(17, 19) == 323);
    try std.testing.expect(lcm(18, 20) == 180);
    try std.testing.expect(lcm(19, 21) == 399);
    try std.testing.expect(lcm(20, 22) == 220);
    try std.testing.expect(lcm(21, 23) == 483);
    try std.testing.expect(lcm(22, 24) == 264);
    try std.testing.expect(lcm(23, 25) == 575);
    try std.testing.expect(lcm(24, 26) == 312);
    try std.testing.expect(lcm(25, 27) == 675);
    try std.testing.expect(lcm(26, 28) == 364);
    try std.testing.expect(lcm(27, 29) == 783);
    try std.testing.expect(lcm(28, 30) == 420);
    try std.testing.expect(lcm(29, 31) == 899);
    try std.testing.expect(lcm(30, 32) == 480);
}
