const std = @import("std");

const Token = union(enum) {
    identifier: []const u8,
    integer_literal: []const u8,

    // Keywords

    // NOTE: We need to use the label @"var" to not interfer with the Zig compiler that use the var keyword too
    @"var",                             // var

    // Punctuation
    equal,                              // =
    semicolon,                          // ;

    // Useful stuff
    illegal,
    eof,

    fn keyword(ident: []const u8) ?Token {
        const map = std.StaticStringMap(Token).initComptime(.{
            .{ "var", Token.@"var" },
        });
        return map.get(ident);
    }
};


pub const Lexer = struct {
    const Self = @This();

    read_pos: usize = 0,
    pos: usize = 0,
    ch: u8 = 0,
    input: []const u8,

    pub fn init(input: []const u8) Self {
        const lex = Self {
            .input = input,
        };

        return lex;
    }
};