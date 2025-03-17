---@return { filePath: string, className: string, packagePath: string, packageName: string } | nil
local function getCurrentFileInfo()
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
	if not packagePath then
		vim.notify("Could not determine package path", vim.log.levels.ERROR)
		return
	end

	local packageName = packagePath:gsub("/", ".")
	if not packageName then
		vim.notify("Could not determine package name", vim.log.levels.ERROR)
		return
	end

	return {
		filePath = filePath,
		className = className,
		packagePath = packagePath,
		packageName = packageName,
	}
end

---@param directory string
---@return { filePath: string, className: string, packagePath: string, packageName: string, testPackageDir: string, testFileName: string } | nil
local function getTestFileInfo(directory)
	local fileInfo = getCurrentFileInfo()

	if fileInfo == nil then
		return
	end

	local testPackageDir = directory .. fileInfo.packagePath
	local testFileName = string.format("%s/%sTest.java", testPackageDir, fileInfo.className)

	return {
		filePath = fileInfo.filePath,
		className = fileInfo.className,
		packagePath = fileInfo.packagePath,
		packageName = fileInfo.packageName,
		testPackageDir = testPackageDir,
		testFileName = testFileName,
	}
end

return {
	fileInfo = getCurrentFileInfo,
	testFileInfo = getTestFileInfo,
}
