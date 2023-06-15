const std = @import("std");

const Node = struct {
    left: ?*Node,
    value: u32,
    right: ?*Node,
};

test "empty binary tree" {
    const tree = Node{ .left = null, .value = 42, .right = null };

    std.debug.print("tree = {}\n", .{tree});
    try std.testing.expectEqual(tree.left, null);
    try std.testing.expectEqual(tree.right, null);
    try std.testing.expectEqual(tree.value, 42);
}

test "basic binary tree" {
    var left = Node{ .left = null, .value = 21, .right = null };
    var far_right = Node{ .left = null, .value = 168, .right = null };
    var right = Node{ .left = null, .value = 84, .right = &far_right };
    const tree = Node{ .left = &left, .value = 42, .right = &right };

    std.debug.print("tree = {}\n", .{tree});
    try std.testing.expectEqual(tree.value, 42);
    try std.testing.expectEqual(tree.left.?.value, 21);
    try std.testing.expectEqual(tree.right.?.value, 84);
    try std.testing.expectEqual(tree.right.?.right.?.value, 168);
}

test "basic enum" {
    const Pet = enum { Dog, Cat, Fish, Iguana, Platypus };

    std.debug.print("Ed's favorite pet is {s}.\n", .{@tagName(Pet.Cat)});

    const Binary = enum(u1) { Zero = 0, One = 1 };

    std.debug.print("There are {d}{d} types of people in this world, those understand binary and those who don't.\n", .{ @enumToInt(Binary.One), @enumToInt(Binary.Zero) });

    // all my subjectively objective opinions are mine alone
    // any similiarity to your opinion is purely coincidental
    const fav: Pet = .Cat;
    std.debug.print("{s} is ", .{@tagName(fav)});
    switch (fav) {
        .Dog => std.debug.print("needy!\n", .{}),
        .Cat => std.debug.print("perfect!\n", .{}),
        .Fish => std.debug.print("so much work!\n", .{}),
        .Iguana => std.debug.print("not tasty!\n", .{}),
        else => std.debug.print("legal?\n", .{}),
    }

    // switch is actually an expression not just a statement
    const score = switch (fav) {
        .Dog => 50,
        .Cat => 100,
        .Fish => 25,
        .Iguana => 15,
        else => 75,
    };
    std.debug.print("score is {d}\n", .{score});
}

test "non-exhaustive enum" {
    const Eds = enum(u8) {
        Ed,
        Edward,
        Edmond,
        Eduardo,
        Edwin,
        Eddy,
        Eddie,
        _,
    };

    const ed = Eds.Ed;

    std.debug.print("All your code are belong to ", .{});
    switch (ed) {
        // Zig switch uses , not | for mutiple options
        .Ed, .Edward => std.debug.print("{s}!\n", .{@tagName(ed)}),
        // can use capture
        .Edmond, .Eduardo, .Edwin, .Eddy, .Eddie => |name| std.debug.print("this {s}!\n", .{@tagName(name)}),
        // else works but look at the code below for _ vs else
        else => std.debug.print("us\n", .{}),
    }

    // obviously no such enum predefined
    const not_ed = @intToEnum(Eds, 241);
    std.debug.print("All your base are belong to ", .{});
    switch (not_ed) {
        .Ed, .Edward => std.debug.print("{s}!\n", .{@tagName(ed)}),
        .Edmond, .Eduardo, .Edwin, .Eddy, .Eddie => |name| std.debug.print("this {s}!\n", .{@tagName(name)}),
        // _ will force you to handle all defined cases
        // if any of the previous .Ed, .Edward ... .Eddie is missing, this won't compile
        // for example, if you forgot .Edurdo
        // and wrote: .Edmond, .Eduardo, .Edwin, .Eddy, .Eddie => ...
        // the code won't compile
        _ => std.debug.print("us\n", .{}),
    }
}

test "basic union" {
    const Value = union {
        int: i32,
        float: f64,
        string: []const u8,
    };

    var value = Value{ .int = 42 };

    try std.testing.expectEqual(value.int, 42);

    // you can't do this
    // var fval = value.float;
    // std.debug.print("{d}\n", .{fval});

    // you can't do this either
    // var bval = value.string;
    // std.debug.print("{c}\n", .{bval[0]});

    // switch (value) {
    //     .int => std.debug.print("value is int={d}\n", .{value.int}),
    //     .float => std.debug.print("value is float={d}\n", .{value.float}),
    //     .string => std.debug.print("value is string={s}\n", .{value.string}),
    // }
}

test "tagged union" {
    // first define the tags
    const ValueType = enum {
        int,
        float,
        string,
        unknown,
    };

    // not too different from simple union
    const Value = union(ValueType) {
        int: i32,
        float: f64,
        string: []const u8,
        unknown: void,
    };

    // just like the simple union
    var value = Value{ .float = 42.21 };

    try std.testing.expectEqual(value.float, 42.21);

    // you still can't do this
    // var fval = value.float;
    // std.debug.print("{d}\n", .{fval});

    // you can't do this either
    // var bval = value.string;
    // std.debug.print("{c}\n", .{bval[0]});

    // however now you can use the switch expression
    switch (value) {
        .int => std.debug.print("value is int={d}\n", .{value.int}),
        .float => std.debug.print("value is float={d}\n", .{value.float}),
        .string => std.debug.print("value is string={s}\n", .{value.string}),
        else => std.debug.print("value is unknown!\n", .{}),
    }

    var value2 = Value{ .string = "I'm Ed" };

    switch (value2) {
        .int => |v| std.debug.print("captured value is int={d}\n", .{v}),
        .float => |v| std.debug.print("captured value is float={d}\n", .{v}),
        .string => |v| std.debug.print("captured value is string={s}\n", .{v}),
        else => std.debug.print("captured value is unknown!\n", .{}),
    }

    switch (value2) {
        .int => |*v| v.* += 1,
        .float => |*v| v.* = v.* * v.*,
        .string => |*v| v.* = "I'm not Ed",
        else => std.debug.print("modifying unknown value not allowed!\n", .{}),
    }
    std.debug.print("modified value is {s}\n", .{value2.string});
}
