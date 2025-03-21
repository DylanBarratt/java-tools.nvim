-- TODO:
--      custom keymaps
--      option for how file name is formatted (could take function)
--      offer new test option

local options = require("java-tools").opts
local borderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
local title = "Tests"

local function getFileName(path)
  return path:match("([^/\\]+)$")
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

local function openFloatingWindow(files)
  ---@type string[]
  local fileShortNames = {}
  local longestLen = 0
  for _, fileLoc in ipairs(files) do
    local shortName = getFileName(fileLoc)
    table.insert(fileShortNames, shortName)
    if #shortName > longestLen then
      longestLen = #shortName
    end
  end

  local bufnr = vim.api.nvim_create_buf(false, true)

  local width = math.min(longestLen * 2, vim.o.columns)
  local height = #files
  local zindex = 999

  local borderWinId = openBorderWindow(width, height, #fileShortNames, zindex)

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

  -- open file
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = function()
      local cursor = vim.api.nvim_win_get_cursor(winId)
      local selected_file = files[cursor[1]]
      if selected_file then
        vim.api.nvim_win_close(borderWinId, true)
        vim.api.nvim_win_close(winId, true)
        vim.cmd("edit " .. selected_file)
      end
    end,
  })

  -- close window
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "", {
    noremap = true,
    silent = true,
    callback = function()
      vim.api.nvim_win_close(borderWinId, true)
      vim.api.nvim_win_close(winId, true)
    end,
  })
end

local function goToTest()
  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = false }

  vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, _, _)
    if err then
      vim.notify("Error finding references: " .. err.message, vim.log.levels.ERROR)
      return
    end

    if not result or vim.tbl_isempty(result) then
      vim.notify("No class references found", vim.log.levels.INFO)
      return
    end

    local filteredFiles = {}
    for _, ref in ipairs(result) do
      local path = vim.uri_to_fname(ref.uri or ref.targetUri)

      if
        path:find(vim.fn.getcwd() .. "/" .. options.testDirectory, 1, true)
        and not vim.tbl_contains(filteredFiles, path)
      then
        table.insert(filteredFiles, path)
      end
    end

    if vim.tbl_isempty(filteredFiles) then
      vim.notify("No tests found in " .. options.testDirectory, vim.log.levels.INFO)
      return
    end

    openFloatingWindow(filteredFiles)
  end)
end

return goToTest
