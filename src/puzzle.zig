const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;

const Puzzle1 = @import("puzzles/Puzzle1.zig");

pub fn Puzzle(number: u16) type {
    const PuzzleN = switch (number) {
        1 => Puzzle1,
        else => @compileError("Puzzle does not exist"),
    };

    return struct {
        pub fn solve(gpa: Allocator, reader: *Io.Reader) !void {
            var puzzle = try PuzzleN.init(gpa, reader);
            defer puzzle.deinit(gpa);

            if (@hasDecl(PuzzleN, "solvePart1")) {
                std.debug.print(" Solving part 1:\n", .{});
                const solution = puzzle.solvePart1();
                std.debug.print("  Solution: {d}\n", .{solution});
            }

            if (@hasDecl(PuzzleN, "solvePart2")) {
                std.debug.print(" Solving part 2:\n", .{});
                const solution = puzzle.solvePart2();
                std.debug.print("  Solution: {d}\n", .{solution});
            }
        }
    };
}
