const std = @import("std");
const Lexer = @import("../lexer.zig").Lexer;
const Token = @import("../lexer.zig").Token;

const Parser = struct{
    const Self = @This();

    lexer: Lexer,
    current_token: Token,

    pub fn init(lexer: Lexer) Self {
        var parser = Self {
            .lexer = lexer
        };

        parser.current_token = parser.lexer.next_token();

        return parser;
    }
};