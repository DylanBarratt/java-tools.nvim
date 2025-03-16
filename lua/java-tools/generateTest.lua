local options = require("java-tools").opts.generateTest

local function generateJunitTest()
	local filePath = vim.uri_to_fname(vim.lsp.util.make_position_params().textDocument.uri)
	if not filePath then
		vim.notify("Could not determine file path", vim.log.levels.ERROR)
		return
	end

	local className = filePath:match("([^/]+)%.java$")
	if not className then
		vim.notify("Could not determine class name", vim.log.levels.ERROR)
		return
	end

	local packagePath = filePath:match("src/main/java/(.*)/" .. className .. "%.java$")
	local packageName = packagePath and packagePath:gsub("/", ".") or ""

	local testPackageDir = options.directory .. packagePath
	local testFileName = string.format("%s/%sTest.java", testPackageDir, className)

	vim.fn.mkdir(testPackageDir, "p")

	if vim.fn.filereadable(testFileName) == 0 then
		local file = io.open(testFileName, "w")
		if file then
			file:write(string.format(options.template, packageName, className))
			file:close()
			vim.notify("Test created: " .. testFileName, vim.log.levels.INFO)
		else
			vim.notify("Failed to create test file", vim.log.levels.ERROR)
			return
		end
	else
		vim.notify("Test file already exists: " .. testFileName, vim.log.levels.WARN)
	end

	if options.openTest then
		vim.cmd("edit " .. testFileName)
	end
end

return generateJunitTest
