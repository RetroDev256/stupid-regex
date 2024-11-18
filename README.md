# stupid-regex

*stupid-regex* is a zig package that exposes a module named "stupid-regex".
The package produces a really simple regular expression parser, based off of
<https://www.cs.princeton.edu/courses/archive/spr09/cos333/beautiful.html>.

The parser handles these constructs:
```
    c    matches any literal character c
    .    matches any single character
    ^    matches the beginning of the input string
    $    matches the end of the input string
    *    matches zero or more occurrences of the previous character
```

This is the interface for the parser:
```zig
pub const Match = struct { start: usize, len: usize };
pub fn match(regexp: []const u8, text: []const u8) ?Match { ... }
```

This is an example of how you could use the parser:
```zig
test "stupid-match sanity" {
    try expectEqual(Match{ .start = 0, .len = 0 }, match("", "Hello"));
    try expectEqual(Match{ .start = 1, .len = 1 }, match("e", "Hello"));
    try expectEqual(Match{ .start = 2, .len = 3 }, match("l*o", "Hello"));
    try expectEqual(Match{ .start = 1, .len = 3 }, match("e.l", "Hello"));
    try expectEqual(Match{ .start = 0, .len = 2 }, match("^.*e", "Hello"));

    try expectEqual(null, match("a", "eiouy"));
    try expectEqual(null, match("^b", "abcdef"));

    // When not the last character, $ matches $
    try expectEqual(Match{ .start = 0, .len = 3 }, match("a$e", "a$e"));

    // When not the first character, ^ matches ^
    try expectEqual(Match{ .start = 0, .len = 3 }, match("a^e", "a^e"));

    // Greedy matching means * will prioritize matching zero occurances
    try expectEqual(Match{ .start = 0, .len = 0 }, match(".*", "Hello, World!\n"));
}
```
