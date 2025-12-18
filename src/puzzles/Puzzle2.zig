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
            var buf: [32]u8 = undefined;
            const str = std.fmt.bufPrint(&buf, "{d}", .{num}) catch unreachable;
            const halflen = str.len >> 1;
            if (std.mem.eql(u8, str[0..halflen], str[halflen..])) {
                sum += num;
            }
        }
    }
    return sum;
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
