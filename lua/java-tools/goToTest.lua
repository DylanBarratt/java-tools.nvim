local options = require("java-tools").opts

local function goToTest()
  local testFileInfo = require("java-tools.utils.file").testFileInfo(options.testDirectory)

  if testFileInfo == nil then
    return
  end

  vim.cmd("edit " .. testFileInfo.testFileName)
end

return goToTest
