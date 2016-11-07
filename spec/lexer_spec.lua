describe("lexer", function()
	local lexer = require("fusion.core.lexer")
	it("can do basic assignment", function()
		assert.same(lexer:match("a = b;"), {
			{ "assignment", {
				variable_list = {
					{"variable", "a"},
				},
				expression_list = {
					{"variable", "b"}
				}
			}}
		})
	end)
	it("can do multi value assignment", function()
		assert.same(lexer:match("a, b = c, d;"), {
			{ "assignment", {
				variable_list = {
					{"variable", "a"},
					{"variable", "b"}
				},
				expression_list = {
					{"variable", "c"},
					{"variable", "d"}
				}
			}}
		})
	end)
	it("can do replacement assignment", function()
		assert.same(lexer:match("a, b = b, a;"), {
			{ "assignment", {
				variable_list = {
					{"variable", "a"},
					{"variable", "b"}
				},
				expression_list = {
					{"variable", "b"},
					{"variable", "a"}
				}
			}}
		})
	end)
	it("can do complex expressions", function()
		assert.same(lexer:match("a = (+ (^ b c) (/ d e));"), {
			{"assignment", {
				variable_list = {
					{"variable", "a"}
				},
				expression_list = {{ "expression",
					{"expression",
						{"variable", "b"},
						{"variable", "c"},
						operator = "^",
					},
					{"expression",
						{"variable", "d"},
						{"variable", "e"},
						operator = "/",
					},
					operator = "+",
				}}
			}}
		})
	end)
	it("can translate mathematical constants", function()
		assert.same(lexer:match("a, b, c = 5, -3, 0xAF;"), {
			{"assignment", {
				variable_list = {
					{"variable", "a"},
					{"variable", "b"},
					{"variable", "c"}
				},
				expression_list = {
					{"number", 5, type = "base10"},
					{"number", 3, type = "base10", is_negative = true},
					{"number", 0xAF, type = "base16"}
				}
			}}
		})
	end)
	it("can parse a simple function", function()
		assert.same(lexer:match("func();"), {{"function_call",
			{"variable", "func"}
		}})
	end)
	it("can parse arguments passed to a function", function()
		assert.same(lexer:match("func(test, test_two);"), {{"function_call",
			{"variable", "func"},
			expression_list = {
				{"variable", "test"},
				{"variable", "test_two"}
			}
		}})
	end)
	it("can parse a complex function call", function()
		assert.same(lexer:match("table.instance:method<subclass>(argument);"),{{
			"function_call",
			{"variable", "table", "instance"}, -- tables parse -this- way
			{"variable", "method"},
			expression_list = {
				{"variable", "argument"}
			},
			has_self = true,
			index_class = "subclass"
		}})
	end)
	it("can parse a table", function()
		assert.same(lexer:match("a = {1, b = 2, [c] = 3};"), {{"assignment", {
			variable_list = {{"variable", "a"}},
			expression_list= {
				{"table",
					{"number", 1, type = "base10"},
					{{"number", 2, type = "base10"}, name = "b"},
					{{"number", 3, type = "base10"}, index = {"variable", "c"}}
				}
			}
		}}})
	end)
end)