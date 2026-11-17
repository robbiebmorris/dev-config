local jdtls = require("jdtls")

local root_dir = require("jdtls.setup").find_root({ "packageInfo" }, "Config")
local home = os.getenv("HOME")
local eclipse_workspace = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

local ws_folders_jdtls = {}
if root_dir then
  local file = io.open(root_dir .. "/.bemol/ws_root_folders")
  if file then
    for line in file:lines() do
      table.insert(ws_folders_jdtls, "file://" .. line)
    end
    file:close()
  end
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local config = {
  cmd = {
    "jdtls",
    "--jvm-arg=-javaagent:" .. home .. "/Developer/lombok.jar",
    "-data",
    eclipse_workspace,
  },
  root_dir = root_dir,
  capabilities = capabilities,
  init_options = {
    workspaceFolders = ws_folders_jdtls,
  },
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
}

-- Only start LSP if we're actually in Neovim
if vim.fn.has('nvim') == 1 and vim.api then
  jdtls.start_or_attach(config)
end
