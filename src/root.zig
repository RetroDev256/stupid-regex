const std = @import("std");

pub const Match = struct { start: usize, len: usize };

// Search for regexp anywhere in the text
pub fn match(regexp: []const u8, text: []const u8) ?Match {
    if (regexp.len > 0 and regexp[0] == '^') {
        // A regexp starting with ^ must match a text prefix
        if (matchHere(regexp[1..], text)) |len| {
            return .{ .start = 0, .len = len };
        }
    } else for (0..text.len) |start| {
        // A regexp may match anywhere in the text
        if (matchHere(regexp, text[start..])) |len| {
            return .{ .start = start, .len = len };
        }
    }

    return null;
}

// Search for regexp at beginning of text
fn matchHere(regexp: []const u8, text: []const u8) ?usize {
    // An empty regexp matches an empty slice
    if (regexp.len == 0)
        return 0;
    // Match repeated Characters using *
    if (regexp.len >= 2 and regexp[1] == '*')
        return matchStar(regexp[0], regexp[2..], text);
    // A regexp ending with $ must match a text suffix
    if (regexp.len == 1 and regexp[0] == '$')
        return if (text.len == 0) 0 else null;
    // Recurse for matching characters or the . wildcard
    if (regexp.len >= 1 and (regexp[0] == text[0] or regexp[0] == '.'))
        if (matchHere(regexp[1..], text[1..])) |len|
            return 1 + len;

    return null;
}

// Search for c*regexp at beginning of text
fn matchStar(c: u8, regexp: []const u8, text: []const u8) ?usize {
    for (0..text.len) |start| {
        if (matchHere(regexp, text[start..])) |len|
            return start + len;
        if (text[start] != c and c != '.')
            break;
    }
    // Greedy searching did not find a match
    return null;
}

const expectEqual = std.testing.expectEqual;

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
