const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;

const Self = @This();

ranges: std.ArrayList(Range),

pub fn init(gpa: Allocator, reader: *Io.Reader) !Self {
    var self: Self = .{ .ranges = try .initCapacity(gpa, 8) };
    while (try reader.takeDelimiter(',')) |range_str| {
        const range = try self.ranges.addOne(gpa);
        range.* = .init(range_str);
    }
    return self;
}

pub fn deinit(self: *Self, gpa: Allocator) void {
    self.ranges.deinit(gpa);
}

pub fn solvePart1(self: *Self) u64 {
    var sum: u64 = 0;
    for (self.ranges.items) |*range| {
        for (range.from..range.to + 1) |num| {
            if (checkInvalid1(num)) {
                sum += num;
            }
        }
    }
    return sum;
}

fn checkInvalid1(num: u64) bool {
    var power_of_10: u64 = 10;
    while (power_of_10 * power_of_10 < num) power_of_10 *= 10;
    const first_half = num / power_of_10;
    const second_half = @mod(num, power_of_10);

    if (second_half < power_of_10 / 10) {
        return false;
    }

    return first_half == second_half;
}

pub fn solvePart2(self: *Self) u64 {
    var sum: u64 = 0;
    for (self.ranges.items) |*range| {
        for (range.from..range.to + 1) |num| {
            if (checkInvalid2(num)) {
                sum += num;
            }
        }
    }
    return sum;
}

fn checkInvalid2(num: u64) bool {
    var power_of_10: u64 = 10;
    outer: while (power_of_10 * power_of_10 / 10 < num) : (power_of_10 *= 10) {
        const expect_mod = @mod(num, power_of_10);
        // this check ensures that sequence doesn't start with a zero
        // ex. 1230123 with power_of_10 of 10000
        if (expect_mod < power_of_10 / 10) {
            continue;
        }

        var num_left = num / power_of_10;
        while (num_left > 0) {
            const mod = @mod(num_left, power_of_10);
            if (mod != expect_mod or mod < power_of_10 / 10) {
                continue :outer;
            }
            num_left = num_left / power_of_10;
        }
        return true;
    }
    return false;
}

const Range = struct {
    from: u64,
    to: u64,

    pub fn init(buf: []const u8) Range {
        const trimmed = std.mem.trim(u8, buf, " \n");
        var split = std.mem.splitScalar(u8, trimmed, '-');
        return .{
            .from = std.fmt.parseInt(u64, split.next().?, 10) catch unreachable,
            .to = std.fmt.parseInt(u64, split.next().?, 10) catch unreachable,
        };
    }
};

test "checkInvalid2: valid 111111111" {
    try std.testing.expect(checkInvalid2(111111111));
}

test "checkInvalid2: valid 123123" {
    try std.testing.expect(checkInvalid2(123123));
}

test "checkInvalid2: valid 1212121212" {
    try std.testing.expect(checkInvalid2(1212121212));
}

test "checkInvalid2: invalid 111111110" {
    try std.testing.expect(!checkInvalid2(111111110));
}

test "checkInvalid2: invalid 1230123" {
    try std.testing.expect(!checkInvalid2(1230123));
}
