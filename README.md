# Zig Union(Enum) – WTF is switch(union(enum))

The power and complexity of **Union(Enum)** in Zig

---

Ed Yu ([@edyu](https://github.com/edyu) on Github and
[@edyu](https://twitter.com/edyu) on Twitter)
Jun.13.2023

---

![Zig Logo](https://ziglang.org/zig-logo-dark.svg)

## Introduction

[**Zig**](https://ziglang.org) is a modern system programming language and
although it claims to a be a **better C**, many people who initially didn't
need system programming were attracted to it due to the simplicity of its
syntax compared to alternatives such as **C++** or **Rust**.

However, due to the power of the language, some of the syntax are not obvious
for those first coming into the language. I was actually one such person.

One of my favorite languages is [**Haskell**](https://www.haskell.org) and
if you ever thought that you prefer a typed language you owe it to yourself
to learn **Haskell** at least once so you can appreciate how many other
languages "borrowed" their type systems from it. I can promise you that you'll
come out a better programmer.

## ADT

One of the most widely used features and the underlying foundation of the
**Haskell** type system is the _ADT_ or [_Algebraic Data Types_](https://wiki.haskell.org/Algebraic_data_type)
(not to be confused with [_Abstract Data Types_](https://wiki.haskell.org/Abstract_data_type)).
You can look up the difference on [StackOverflow](https://stackoverflow.com/questions/42833270/what-is-the-difference-between-abstract-data-types-and-algebraic-data-types).

However, for us programmers, you can just think of _Abstract Data Types_ as
either a _struct_ or a simple _class_ (simple as in not nested).

For _ADT_ or _Algebraic Data Types_, we need to have access to _union_ for
those that has experienced it before in languages that provide such construct
such as **C** or in our case **Zig**.

**Note**: In order for _ADT_ to be called _Algebraic_, it needs to support both
_sum_ and _product_.
_Sum_ means that the type needs to support A or B but not both together,
whereas _product_ means the type needs to support A and B together.

## Why do we care?

The main reason for _ADT_ to exist is so that you can express the concept of a
type that can be in multiple states or forms. In other words, you can say that
an object of that type can be either this or that, or something else.

For example, for a typical tree structure, you can say a tree node is either a
leaf or a node that contains either other nodes or a leaf.

Another example would be that for a linked list, you can say that the list is
formed recursively by a node that _points_ to either another node or by the
end of the list.

However, to show how we can use _ADT_ in **Zig**, we have to explain some other
concepts first.

## Zig Struct

The foundation of data types in **Zig** is the _struct_.
In fact, it's pretty much everywhere in **Zig**.

The _struct_ in **Zig** is probably the closest thing to a _class_ in most
object-oriented programming languages.

Here is the basic idea:

```zig
// if you want to try yourself, you must import `std`
const std = @import("std");

// let's construct a binary tree node
const BinaryTree = struct {
    // a binary tree has a left subtree and a right subtree
    left: ?*BinaryTree,
    // for simplicity, let's just say we have an unsigned 32-bit integer value
    value: u32,
    right: ?*BinaryTree,
};

const tree = BinaryTree{ .left = null, .value = 42, .right = null };
```

There are several things of note here in the code above:

1. If you are not familiar with `?`, you are welcome to look over [Zig If - WTF](https://zig.news/edyu/zig-if-wtf-is-bool-48hh).
   It basically means that the variable can either have a value of the type after
   `?` or if it doesn't then it will take on a value of `null`.

2. We are referring to the _BinaryTree_ type inside the _BinaryTree_ type definition as
   a tree is a recursive structure.

3. However, you must use the `*` to denote that _left_ and _right_ are
   pointers to another _BinaryTree_ struct. If you leave out the pointer then the
   compiler will complain because then the size of _BinaryTree_ is dynamic as it can
   grow to be arbitrarily big as we add more sub-trees.

The following code will show a slightly more complex tree structure.
Note that we have to use `&` in order to get the pointer of the _BinaryTree_ struct.

```zig
    var left = BinaryTree{ .left = null, .value = 21, .right = null };
    var far_right = BinaryTree{ .left = null, .value = 168, .right = null };
    var right = BinaryTree{ .left = null, .value = 84, .right = &far_right };

    const tree2 = BinaryTree{ .left = &left, .value = 42, .right = &right };
```

## Zig Enum

Sometimes, a _struct_ is an overkill if you just want to have a set of possible
values for a variable to take and restrict the variable to take only a value
from the set. Usually, we would use _enum_ for such a use case.

```zig
// sorry if I left our your favorite pet
const Pet = enum { Dog, Cat, Fish, Iguana, Platypus };

const fav: Pet = .Cat;

// Each of the value of an enum is called a tag
std.debug.print("Ed's favorite pet is {s}.\n", .{@tagName(Pet.Cat)});

// you can specify what type and what value the enum takes
const Binary = enum(u1) { Zero = 0, One = 1 };

std.debug.print("There are {d}{d} types of people in this world, those understand binary and those who don't.\n", .{
    @enumToInt(Binary.One),
    @enumToInt(Binary.Zero)
});
```

## Switch on Enum

One of the most convenient constructs for an _enum_ is the _switch_ expression.
In **Haskell**, the reason _ADT_ is so useful is the ability to pattern match
on the _switch_ expression. In fact, **Haskell**, function definition is
basically a super-charged switch statement.

So how do we use _switch_ statement in **Zig**?

```zig
const fav: Pet = .Cat;

std.debug.print("{s} is ", .{@tagName(fav)});
switch (fav) {
    .Dog => std.debug.print("needy!\n", .{}),
    .Cat => std.debug.print("perfect!\n", .{}),
    .Fish => std.debug.print("so much work!\n", .{}),
    .Iguana => std.debug.print("not tasty!\n", .{}),
    else => std.debug.print("legal?\n", .{}),
}

const score = switch (fav) {
    .Dog => 50,
    .Cat => 100,
    .Fish => 25,
    .Iguana => 15,
    else => 75,
};
```

## Union

In _C_ and in _Zig_, _union_ is similar to _struct_, except that instead of
the structure having all the fields, only one of the fields of the _union_ is
active. For those familiar with _C_ union, please be aware that _Zig_ union
cannot be used to reinterpret memory. So in other words, you cannot use
one field of the _union_ to **cast** the value defined by another field type.

```zig
const Value = union {
    int: i32,
    float: f64,
    string: []const u8,
};

var value = Value{ .int = 42 };
// you can't do this
var fval = value.float;
std.debug.print("{d}\n", .{fval});

// you can't do this, either
var bval = value.string;
std.debug.print("{c}\n", .{bval[0]});
```

## Switch on Union

Well, you cannot use _switch_ on _union_; at least not on simple _union_.

```zig
// won't compile
switch (value) {
    .int => std.debug.print("value is int={d}\n", .{value.int}),
    .float => std.debug.print("value is float={d}\n", .{value.float}),
    .string => std.debug.print("value is string={s}!\n", .{value.string}),
}
```

## Union(Enum) is Tagged Union

The error message on the previous example will actual say:
`note: consider 'union(enum)' here`.

The **Zig** nomenclature for `union(enum)` is actually called tagged _union_.
As we mentioned earlier, the individual fields of an _enum_ are called tags.

Tagged _union_ was created so that they can be used in _switch_ expressions.

```zig
switch (value) {
    .int => std.debug.print("value is int={d}\n", .{value.int}),
    .float => std.debug.print("value is float={d}\n", .{value.float}),
    .string => std.debug.print("value is string={s}\n", .{value.string}),
    else => std.debug.print("value is unknown!\n", .{}),
}
```

## Capture Tagged Union Value

You can use the capture in the _switch_ expression if you need to access the
value.

```zig
switch (value) {
    .int => |v| std.debug.print("value is int={d}\n", .{v}),
    .float => |v| std.debug.print("value is float={d}\n", .{v}),
    .string => |v| std.debug.print("value is string={s}\n", .{v}),
    else => std.debug.print("value is unknown!\n", .{}),
}
```

## Modify Tagged Union

If you need to modify the value, you have to use convert the value to a
pointer in the capture using `*`.

```zig
switch (value) {
    .int => |*v| v.* += 1,
    .float => |*v| v.* ^= 2,
    .string => |*v| v.* = "I'm not Ed",
    else => std.debug.print("value is unknown!\n", .{}),
}
```

## Tagged Union as ADT

We now have everything we need to implement **Zig** version of _ADT_.
What makes _ADT_ useful is that not only it will tell you the state but also
the context of the state.

Using **Zig** for instance, the active tag in a `union` will tell you the state,
and if the _tag_ is a type that has a value, then the value is the context.

```zig
// this example is fairly involved, please see the full code on github
// You can find the code at https://github.com/edyu/wtf-zig-adt/blob/master/testadt.zig
const NodeType = enum {
    tip,
    node,
};

const Tip = struct {};

const Node = struct {
    left: *const Tree,
    value: u32,
    right: *const Tree,
};

const leaf = Tip{};

// this is meant to reimplement the binary tree example on https://wiki.haskell.org/Algebraic_data_type
// if you call tree.toString(), it will print out:
// Node (Node (Node (Tip 1 Tip) 3 Node (Tip 4 Tip)) 5 Node (Tip 7 Tip))
const tree = Tree{ .node = &Node{
    .left = &Tree{ .node = &Node{
        .left = &Tree{ .node = &Node{
            .left = &Tree{ .tip = leaf },
            .value = 1,
            .right = &Tree{ .tip = leaf } } },
        .value = 3,
        .right = &Tree{ .node = &Node{
            .left = &Tree{ .tip = leaf },
            .value = 4,
            .right = &Tree{ .tip = leaf } } } } },
    .value = 5,
    .right = &Tree{ .node = &Node{
        .left = &Tree{ .tip = leaf },
        .value = 7,
        .right = &Tree{ .tip = leaf } } } } };
// see the full example on github
```

## Bonus

In **Zig**, there is also something called _non-exhaustive enum_.

_Non-exhaustive enum_ must be defined with an integer tag type in the `()`.
You then put `_` as the last tag in the _enum_ definition.

Instead of `else`, you can use `_` to ensure you handled all the cases in the
_switch_ expression.

```zig
const Eds = enum {
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
    // Zig switch uses , not | for multiple options
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
```

## The End

You can find the code [here](https://github.com/edyu/wtf-zig-adt/blob/master/testadt.zig).

## ![Zig Logo](https://ziglang.org/zero.svg)
