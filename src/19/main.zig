const std = @import("std");
const utils = @import("../utils.zig");
const Allocator = std.mem.Allocator;
const iter_lines = utils.iter_lines;

const Part = struct {
    x: u32,
    m: u32,
    a: u32,
    s: u32,
};

fn deserialize_part(inp: []const u8) Part {
    var part = Part{
        .x = 0,
        .m = 0,
        .a = 0,
        .s = 0,
    };

    var stream = std.io.fixedBufferStream(inp);
    var reader = stream.reader();

    _ = reader.readByte() catch unreachable;

    var buffer: [256]u8 = undefined;

    _ = reader.readUntilDelimiter(&buffer, '=') catch unreachable;
    part.x = std.fmt.parseUnsigned(u32, reader.readUntilDelimiter(&buffer, ',') catch unreachable, 10) catch unreachable;

    _ = reader.readUntilDelimiter(&buffer, '=') catch unreachable;
    part.m = std.fmt.parseUnsigned(u32, reader.readUntilDelimiter(&buffer, ',') catch unreachable, 10) catch unreachable;

    _ = reader.readUntilDelimiter(&buffer, '=') catch unreachable;
    part.a = std.fmt.parseUnsigned(u32, reader.readUntilDelimiter(&buffer, ',') catch unreachable, 10) catch unreachable;

    _ = reader.readUntilDelimiter(&buffer, '=') catch unreachable;
    part.s = std.fmt.parseUnsigned(u32, reader.readUntilDelimiter(&buffer, '}') catch unreachable, 10) catch unreachable;

    return part;
}

const Instruction = struct {
    variable: u8,
    greater: bool,
    value: u32,
    target: []const u8,
};

const InstructionGroup = struct {
    name: []const u8,
    instructions: []Instruction,

    fn deinit(self: InstructionGroup, allocator: *const Allocator) void {
        allocator.free(self.instructions);
    }
};

fn deserialize_instruction_group(inp: []const u8, allocator: *const Allocator) InstructionGroup {
    var inp_i: usize = 0;

    const instructions_count = std.mem.count(u8, inp, ",") + 1;
    var instructions = allocator.alloc(Instruction, instructions_count) catch unreachable;

    const openParaI = std.mem.indexOfScalar(u8, inp, '{') orelse unreachable;
    const name = inp[0..openParaI];
    inp_i = openParaI + 1;

    var instructionI: usize = 0;
    const group = InstructionGroup{
        .name = name,
        .instructions = instructions,
    };

    while (true) {
        const colon_i = std.mem.indexOfScalarPos(u8, inp, inp_i, ':');

        if (colon_i) |colon_idx| {
            instructions[instructionI].variable = inp[inp_i];
            instructions[instructionI].greater = inp[inp_i + 1] == '>';
            instructions[instructionI].value = std.fmt.parseUnsigned(u32, inp[inp_i + 2 .. colon_idx], 10) catch unreachable;
            const comma_i = std.mem.indexOfScalarPos(u8, inp, colon_idx, ',') orelse unreachable;
            instructions[instructionI].target = inp[colon_idx + 1 .. comma_i];
            instructionI += 1;
            inp_i = comma_i + 1;

            var asdf = "a";
            if (instructions[instructionI].greater) {
                asdf = ">";
            } else {
                asdf = "<";
            }
            // const instruction = instructions[instructionI];
            // std.debug.print("DESERIALIZE {c} {s} {d} {s}\n", .{ instruction.variable, asdf, instruction.value, instruction.target });
        } else {
            const closingParaI = std.mem.indexOfScalar(u8, inp, '}') orelse unreachable;
            instructions[instructionI].variable = '#';
            instructions[instructionI].target = inp[inp_i..closingParaI];
            break;
        }
    }

    return group;
}

fn get_next_state(instructions: []Instruction, part: Part) []const u8 {
    for (instructions) |instruction| {
        if (instruction.variable == '#') {
            return instruction.target;
        }

        var part_value: u32 = 0;
        switch (instruction.variable) {
            'x' => part_value = part.x,
            'm' => part_value = part.m,
            'a' => part_value = part.a,
            's' => part_value = part.s,
            else => unreachable,
        }

        if (instruction.greater) {
            if (part_value > instruction.value) {
                return instruction.target;
            }
        } else {
            if (part_value < instruction.value) {
                return instruction.target;
            }
        }
    }

    unreachable;
}

pub fn solve_1(inp: []const u8, allocator: *const Allocator) u32 {
    var line_iter = iter_lines(inp);
    var instructions = std.StringHashMap([]Instruction).init(allocator.*);
    defer instructions.deinit();

    while (line_iter.next()) |line| {
        if (line.len == 0) {
            break;
        }

        const group = deserialize_instruction_group(line, allocator);
        instructions.put(group.name, group.instructions) catch unreachable;
    }

    var result: u32 = 0;
    while (line_iter.next()) |line| {
        const part = deserialize_part(line);
        var state: []const u8 = "in";
        while (true) {
            const group = instructions.get(state) orelse unreachable;
            state = get_next_state(group, part);
            if (std.mem.eql(u8, state, "A")) {
                result += part.x + part.m + part.a + part.s;
                break;
            }
            if (std.mem.eql(u8, state, "R")) {
                break;
            }
        }
    }

    var instructions_iter = instructions.valueIterator();
    while (instructions_iter.next()) |insts| {
        allocator.free(insts.*);
    }

    return result;
}

pub fn solve_2(inp: []const u8, allocator: *const Allocator) u64 {
    _ = inp;
    _ = allocator;
    return 0;
}

const example_input = @embedFile("input-example.txt");
const input = @embedFile("input.txt");

test "deserialize_part" {
    const part = deserialize_part("{x=787,m=2655,a=1222,s=2876}");
    try std.testing.expectEqual(787, part.x);
    try std.testing.expectEqual(2655, part.m);
    try std.testing.expectEqual(1222, part.a);
    try std.testing.expectEqual(2876, part.s);
}

test "deserialize_instruction_group" {
    const group = deserialize_instruction_group("px{a<2006:qkq,m>2090:A,rfg}", &std.testing.allocator);
    defer group.deinit(&std.testing.allocator);

    try std.testing.expectEqualStrings("px", group.name);
    try std.testing.expectEqual(3, group.instructions.len);
    try std.testing.expectEqual('a', group.instructions[0].variable);
    try std.testing.expectEqual(false, group.instructions[0].greater);
    try std.testing.expectEqual(2006, group.instructions[0].value);
    try std.testing.expectEqualStrings("qkq", group.instructions[0].target);
    try std.testing.expectEqual('m', group.instructions[1].variable);
    try std.testing.expectEqual(true, group.instructions[1].greater);
    try std.testing.expectEqual(2090, group.instructions[1].value);
    try std.testing.expectEqualStrings("A", group.instructions[1].target);
    try std.testing.expectEqual('#', group.instructions[2].variable);
    try std.testing.expectEqualStrings("rfg", group.instructions[2].target);
}

test "solve_1" {
    try std.testing.expectEqual(@as(u32, 19114), solve_1(example_input, &std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 367602), solve_1(input, &std.testing.allocator));
}

test "solve_2" {
    try std.testing.expectEqual(@as(u32, 0), solve_2(example_input, &std.testing.allocator));
    try std.testing.expectEqual(@as(u32, 0), solve_2(input, &std.testing.allocator));
}
