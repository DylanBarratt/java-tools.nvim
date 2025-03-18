local M = {}

function SetupCommands()
  if M.opts.generateTest.enabled then
    vim.api.nvim_create_user_command("JavaGenerateTest", require("java-tools.generateTest"), { desc = "Generate test" })
  end

  if M.opts.goToTest.enabled then
    vim.api.nvim_create_user_command("JavaGoToTest", require("java-tools.goToTest"), { desc = "Go to class test" })
  end
end

M.setup = function(opts)
  M.opts = vim.tbl_deep_extend("force", require("java-tools.options"), opts)

  SetupCommands()
end

return M
