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


fn isLetter(ch: u8) bool {
    return std.ascii.isAlphabetic(ch) or ch == '_';
}

fn isIntegerLiteral(ch: u8) bool {
    return std.ascii.isDigit(ch);
}

pub const Lexer = struct {
    const Self = @This();

    read_pos: usize = 0,
    pos: usize = 0,
    ch: u8 = 0,
    input: []const u8,

    pub fn init(input: []const u8) Self {
        var lex = Self {
            .input = input,
        };

        lex.read_char();

        return lex;
    }

    fn read_char(self: *Self) void {
        if (self.read_pos >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_pos];
        }

        self.pos = self.read_pos;
        self.read_pos += 1;
    }

    fn read_identifier(self: *Self) []const u8 {
        const position = self.pos;

        while (isLetter(self.ch)) {
            self.read_char();
        }

        return self.input[position..self.pos];
    }

    fn peek_char(self: *Self) u8 {
        if (self.read_position >= self.input.len) {
            return 0;
        } else {
            return self.input[self.read_position];
        }
    }

    pub fn next_token(self: *Self) Token {
        self.skip_whitespace();
        const tok: Token = switch (self.ch) {
            ';' => .semicolon,
            // TODO: For equality comparison
            //'=' => blk: {
            //    if (self.peek_char() == '=') {
            //        self.read_char();
            //        break :blk .equal;
            //    } else {
            //        break :blk .assign;
            //    }
            //},
            '=' => .equal,
            0 => .eof,
            'a'...'z', 'A'...'Z', '_' => {
                const ident = self.read_identifier();
                if (Token.keyword(ident)) |token| {
                    return token;
                }
                return .{ .identifier = ident };
            },
            '0'...'9' => {
                const int = self.read_integer_literal();
                return .{ .integer_literal = int };
            },
            else => .illegal,
        };

        self.read_char();
        return tok;
    }

    fn read_integer_literal(self: *Self) []const u8 {
        const position = self.pos;

        while (isIntegerLiteral(self.ch)) {
            self.read_char();
        }

        return self.input[position..self.pos];
    }

    fn skip_whitespace(self: *Self) void {
        while (std.ascii.isWhitespace(self.ch)) {
            self.read_char();
        }
    }
};

const expectEqualDeep = std.testing.expectEqualDeep;
test "Variable Declaration - Lexer" {
    const input = "var my_amazing_variable = 1;";
    var lex = Lexer.init(input);

    const expected = [_]Token{
        .@"var",
        .{ .identifier = "my_amazing_variable" },
        .equal,
        .{ .integer_literal = "1" },
        .semicolon,
        .eof,
    };

    for (expected) |token| {
        const tok = lex.next_token();

        try expectEqualDeep(token, tok);
    }
}