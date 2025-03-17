---@return table | nil
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
	local packageName = packagePath and packagePath:gsub("/", ".") or ""

	return {
		filePath = filePath,
		className = className,
		packagePath = packagePath,
		packageName = packageName,
	}
end

---@param directory string
---@return table | nil
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
