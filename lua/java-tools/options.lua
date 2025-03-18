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

---@type Options
return {
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
}
