const std = @import("std");

pub fn main() !void {
    var buffer: [4 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    var iter = try std.process.argsWithAllocator(allocator);
    defer iter.deinit();
    const stdout = std.io.getStdOut();

    var allArgs = std.ArrayList([:0]const u8).init(allocator);
    try allArgs.append("cmd.exe");
    try allArgs.append("/C");

    var idx: u8 = 0;
    outer: while (true) {
        const arg = iter.next();
        if (idx == 0) {
            idx += 1;
            continue;
        }

        if (arg) |a| {
            try allArgs.append(a);
        } else {
            break :outer;
        }
    }

    var timer = try std.time.Timer.start();
    std.debug.print("len: {d}\n", .{allArgs.items.len});
    for (allArgs.items) |a| std.debug.print("Arg: {s}\n", .{a});
    const slice: []const []const u8 = allArgs.items;
    var proc = std.process.Child.init(slice, allocator);
    _ = try proc.spawnAndWait();

    _ = try stdout.write(try formatTS(allocator, timer.read()));
    std.debug.print("EndIndex of fba '{d}', length '{d}'", .{ fba.end_index, buffer.len });
}

fn formatTS(allocator: std.mem.Allocator, ns: u64) ![]const u8 {
    if (ns > 999_999_999) {
        return try std.fmt.allocPrint(allocator, "\nFinished execution in: {d}ms (~{d}s)\n", .{ ns / 1000_000, ns / 1000_000_000 });
    }
    return try std.fmt.allocPrint(allocator, "\nFinished execution in: {d}ms\n", .{ns / 1000_000});
}
