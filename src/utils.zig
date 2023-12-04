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
