--------------------------------------------------------------------------------

local M = {
	opts = {
		generateTest = {
			enabled = true,
			directory = "src/test/java/",
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
	},
}

--------------------------------------------------------------------------------

function Main()
	if M.opts.generateTest.enabled then
		vim.api.nvim_create_user_command(
			"JavaGenerateTest",
			require("java-tools.generateTest"),
			{ desc = "JDTLS Code Action Menu" }
		)
	end
end

--------------------------------------------------------------------------------

M.setup = function(opts)
	if opts ~= nil and vim.tbl_count(opts) > 0 then
		-- is this needed? makes plugin slow to load...
		vim.validate({
			opts = { opts, "table", true },
			opts_generateTest = { opts.generateTest, "table", true },
			opts_generateTest_enabled = { opts.generateTest.enabled, "boolean", true },
			opts_generateTest_directory = { opts.generateTest.directory, "string", true },
			opts_generateTest_template = { opts.generateTest.template, "string", true },
			opts_generateTest_openTest = { opts.generateTest.openTest, "boolean", true },
		})
		M.opts = opts
	end

	Main()
end

return M
