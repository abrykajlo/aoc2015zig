const std = @import("std");
const Io = std.Io;

const Puzzle = @import("puzzle.zig").Puzzle;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    var threaded = std.Io.Threaded.init(allocator);
    defer threaded.deinit();
    const io = threaded.io();

    _ = args.next();
    const puzzle = if (args.next()) |n| try std.fmt.parseInt(u16, n, 10) else return error.NotEnoughArgs;

    switch (puzzle) {
        inline 1...2 => |p| {
            var filename_buf: [128]u8 = undefined;
            const filename = try std.fmt.bufPrint(&filename_buf, "./data/puzzle{d}.txt", .{puzzle});
            const file = try Io.Dir.cwd().openFile(io, filename, .{});
            defer file.close(io);

            var buf: [1024]u8 = undefined;
            var reader = file.reader(io, &buf);

            std.debug.print("Solving Puzzle {d}:\n", .{puzzle});
            try Puzzle(p).solve(allocator, &reader.interface);
        },
        else => {
            std.debug.print("Puzzle {d} does not exist\n", .{puzzle});
            return error.PuzzleDoesNotExist;
        },
    }
}
