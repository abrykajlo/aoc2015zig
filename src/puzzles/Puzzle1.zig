const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;

const Self = @This();

const START_VALUE = 50;
const MAX_VALUE = 100;

rotations: std.ArrayList(Rotation),

pub fn init(gpa: Allocator, reader: *Io.Reader) !Self {
    var self: Self = .{ .rotations = try .initCapacity(gpa, 8) };
    try self.parseRotations(gpa, reader);
    return self;
}

pub fn deinit(self: *Self, gpa: Allocator) void {
    self.rotations.deinit(gpa);
}

fn parseRotations(self: *Self, gpa: Allocator, reader: *Io.Reader) !void {
    while (try reader.takeDelimiter('\n')) |line| {
        const entry = try self.rotations.addOne(gpa);
        entry.* = try .init(line);
    }
}

pub fn solvePart1(self: Self) u32 {
    var value: i32 = START_VALUE;
    var zero_count: u32 = 0;

    for (self.rotations.items) |rotation| {
        switch (rotation) {
            .left => |rot| value -= @intCast(rot),
            .right => |rot| value += @intCast(rot),
        }

        value = @mod(value, MAX_VALUE);
        if (value == 0) {
            zero_count += 1;
        }
    }

    return zero_count;
}

pub fn solvePart2(self: Self) u32 {
    var value: i32 = START_VALUE;
    var zero_count: u32 = 0;

    for (self.rotations.items) |rotation| {
        switch (rotation) {
            .left => |rot| {
                for (0..rot) |_| {
                    value -= 1;
                    value = @mod(value, MAX_VALUE);
                    if (value == 0) {
                        zero_count += 1;
                    }
                }
            },
            .right => |rot| {
                for (0..rot) |_| {
                    value += 1;
                    value = @mod(value, MAX_VALUE);
                    if (value == 0) {
                        zero_count += 1;
                    }
                }
            },
        }
        std.debug.assert(value >= 0);
    }

    return zero_count;
}

const Rotation = union(enum) {
    left: u32,
    right: u32,

    pub fn init(str: []const u8) !Rotation {
        const clicks = try std.fmt.parseInt(u32, str[1..], 10);
        if (str[0] == 'L') {
            return .{ .left = clicks };
        } else {
            return .{ .right = clicks };
        }
    }
};
