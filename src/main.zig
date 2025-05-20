const std = @import("std");

const CmdArgs = struct {
    iter: std.process.ArgIterator,
    collectedArgs: std.ArrayList([:0]const u8),

    pub fn init(allocator: std.mem.Allocator) !CmdArgs {
        return CmdArgs{
            .iter = try std.process.argsWithAllocator(allocator),
            .collectedArgs = std.ArrayList([:0]const u8).init(allocator),
        };
    }

    pub fn getArgs(self: *CmdArgs) ![]const []const u8 {
        try self.collectedArgs.append("cmd.exe");
        try self.collectedArgs.append("/C");

        var skippedFirst = false;
        while (true) {
            const arg = self.iter.next();
            if (!skippedFirst) {
                skippedFirst = true;
                continue;
            }

            if (arg) |a| {
                try self.collectedArgs.append(a);
            } else {
                break;
            }
        }

        const slice: []const []const u8 = self.collectedArgs.items;
        return slice;
    }

    pub fn deinit(self: *CmdArgs) void {
        self.iter.deinit();
        self.collectedArgs.deinit();
    }
};

pub fn main() !void {
    var buffer: [4 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    const stdout = std.io.getStdOut();

    var args = try CmdArgs.init(allocator);
    const commands = try args.getArgs();

    var timer = try std.time.Timer.start();
    var proc = std.process.Child.init(commands, allocator);
    _ = try proc.spawnAndWait();

    _ = try stdout.write(try formatTS(allocator, timer.read()));
}

fn formatTS(allocator: std.mem.Allocator, ns: u64) ![]const u8 {
    if (ns > 999_999_999) {
        return try std.fmt.allocPrint(allocator, "\nFinished execution in: {d}ms (~{d}s)\n", .{ ns / 1000_000, ns / 1000_000_000 });
    }
    return try std.fmt.allocPrint(allocator, "\nFinished execution in: {d}ms\n", .{ns / 1000_000});
}
