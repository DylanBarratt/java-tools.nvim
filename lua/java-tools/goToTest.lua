-- TODO:
--      open test to line where class is first referenced
--      custom keymaps
--      option for how file name is formatted (could take function)

local generateTest = require("java-tools.generateTest")
local options = require("java-tools").opts
local goToOptions = require("java-tools").opts.goToTest
local borderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
local title = "Tests"

local function getFileName(path)
  return path:match("([^/\\]+)$")
end

---@param bufnr number
---@param winId number
---@param filePaths string[]
---@param generateNewTest boolean
local function keymaps(bufnr, winId, filePaths, generateNewTest)
  -- open file
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = function()
      local cursor = vim.api.nvim_win_get_cursor(winId)

      vim.api.nvim_win_close(winId, true)

      local selectedFile = filePaths[cursor[1]]
      if selectedFile == nil then
        vim.notify("selected file invalid", vim.log.levels.ERROR)
        return
      end

      if cursor[1] == 1 and generateNewTest and goToOptions.generateTestEnabled then
        generateTest()
      end

      vim.cmd("edit " .. selectedFile)
    end,
  })

  -- close window
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "", {
    noremap = true,
    silent = true,
    callback = function()
      vim.api.nvim_win_close(winId, true)
    end,
  })
end

local function openBorderWindow(width, height, length, zindex)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local winId = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width + 2,
    height = height + 2,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2) - 1,
    border = "none",
    style = "minimal",
    zindex = zindex - 1,
    focusable = false,
  })

  local topLine = borderChars[5]
    .. string.rep(borderChars[1], math.floor((width - #title - 2) / 2))
    .. " "
    .. title
    .. " "
    .. string.rep(borderChars[1], math.ceil((width - #title - 2) / 2))
    .. borderChars[6]
  local bottomLine = borderChars[8] .. string.rep(borderChars[3], width) .. borderChars[7]

  local bufferContent = {}
  table.insert(bufferContent, 1, topLine)
  for _ = 1, length do
    table.insert(bufferContent, borderChars[2] .. string.rep(" ", width) .. borderChars[4])
  end
  table.insert(bufferContent, bottomLine)

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, bufferContent)

  return winId
end

---@param filePaths string[]
---@param fileShortNames string[]
---@param longestLen number
---@param generateNewTest boolean
local function openFloatingWindow(filePaths, fileShortNames, longestLen, generateNewTest)
  local bufnr = vim.api.nvim_create_buf(false, true)

  local width = math.min(longestLen * 2, vim.o.columns)
  local height = #filePaths
  local zindex = 999

  local borderWinId = openBorderWindow(width, height, #filePaths, zindex)

  local winId = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "none",
    zindex = zindex,
  })

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, fileShortNames)

  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })

  keymaps(bufnr, winId, filePaths, generateNewTest)

  -- close border win with main win
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(event)
      if tonumber(event.match) == winId then
        if vim.api.nvim_win_is_valid(borderWinId) then
          vim.api.nvim_win_close(borderWinId, true)
        end
      end
    end,
  })
end

local function goToTest()
  local clients = vim.lsp.get_clients()
  local posParams = vim.lsp.util.make_position_params(0, clients[1].offset_encoding or "utf-16")
  local params =
    { context = { includeDeclaration = false }, position = posParams.position, textDocument = posParams.textDocument }

  vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, _, _)
    if err then
      vim.notify("Error finding references: " .. err.message, vim.log.levels.ERROR)
      return
    end

    local filteredFilesPaths = {} -- paths
    local filteredFilesNames = {} -- displayNames
    local longestLen = 0 -- used to determine window width
    local generateNewTest = false -- used to determine behaviour when selecting test with matching file name

    local testFileInfo = require("java-tools.utils.file").testFileInfo(options.testDirectory)
    if testFileInfo ~= nil then
      local fileName = testFileInfo.testFileName
      local isNew = vim.fn.filewritable(fileName)
      generateNewTest = isNew == 0 and true or false
      local name = getFileName(fileName) .. (generateNewTest and " (new)" or "")
      longestLen = #name
      table.insert(filteredFilesPaths, fileName)
      table.insert(filteredFilesNames, name)
    end

    for _, ref in ipairs(result) do
      local path = vim.uri_to_fname(ref.uri or ref.targetUri)

      if
        path:find(vim.fn.getcwd() .. "/" .. options.testDirectory, 1, true) -- in test directory
        and not vim.tbl_contains(filteredFilesPaths, path) -- not duplicate name
      then
        local name = getFileName(path)
        if #name > longestLen then
          longestLen = #name
        end
        table.insert(filteredFilesPaths, path)
        table.insert(filteredFilesNames, name)
      end
    end


    openFloatingWindow(filteredFilesPaths, filteredFilesNames, longestLen, generateNewTest)
  end)
end

return goToTest
