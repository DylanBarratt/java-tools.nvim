local options = require("java-tools").opts
local generateTestOptions = require("java-tools").opts.generateTest

local function generateJunitTest()
	local testFileInfo = require("java-tools.utils.file").testFileInfo(options.testDirectory)

	if testFileInfo == nil then
		return
	end

	vim.fn.mkdir(testFileInfo.testPackageDir, "p")

	if vim.fn.filereadable(testFileInfo.testFileName) == 0 then
		local file = io.open(testFileInfo.testFileName, "w")
		if file then
			file:write(string.format(generateTestOptions.template, testFileInfo.packageName, testFileInfo.className))
			file:close()
			vim.notify("Test created: " .. testFileInfo.testFileName, vim.log.levels.INFO)
		else
			vim.notify("Failed to create test file", vim.log.levels.ERROR)
			return
		end
	else
		vim.notify("Test file already exists: " .. testFileInfo.testFileName, vim.log.levels.WARN)
	end

	if generateTestOptions.openTest then
		vim.cmd("edit " .. testFileInfo.testFileName)
	end
end

return generateJunitTest
