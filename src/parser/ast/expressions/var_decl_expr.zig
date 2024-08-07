const VarDeclExpr = struct {
    const Self = @This();

    identifier: []const u8,
    value: []const u8,

    pub fn init(identifier: []const u8, value: []const u8) Self {
        return Self {
            .identifier = identifier,
            .value = value
        };
    }
};