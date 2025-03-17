--------------------------------------------------------------------------------

---@class GenerateTestOptions
---@field enabled boolean
---@field template string
---@field openTest boolean

---@class GoToTestOptions
---@field enabled boolean

---@class Options
---@field testDirectory string
---@field generateTest GenerateTestOptions
---@field goToTest GoToTestOptions

local M = {
	---@type Options
	opts = {
		testDirectory = "src/test/java/",
		generateTest = {
			enabled = true,
			template = [[
package %s;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class %sTest {

		@Test
		void testExample() {
				// TODO: Implement test
				assertTrue(true);
		}
}
]],
			openTest = true,
		},

		goToTest = {
			enabled = true,
		},
	},
}

--------------------------------------------------------------------------------

function Main()
	if M.opts.generateTest.enabled then
		vim.api.nvim_create_user_command(
			"JavaGenerateTest",
			require("java-tools.generateTest"),
			{ desc = "Generate test" }
		)
	end

	if M.opts.goToTest.enabled then
		vim.api.nvim_create_user_command("JavaGoToTest", require("java-tools.goToTest"), { desc = "Go to class test" })
	end
end

--------------------------------------------------------------------------------

---@param opts Options
M.setup = function(opts)
	if opts ~= nil then
		M.opts = vim.tbl_deep_extend("force", vim.deepcopy(M.opts), opts)
	end

	Main()
end

return M
