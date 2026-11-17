return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("nvim-tree").setup({
			hijack_netrw = true,
			sync_root_with_cwd = true,
			update_focused_file = { enable = true },
			view = { side = "left", width = 35 },
			renderer = { group_empty = true },
			filters = { dotfiles = false },
		})

		vim.keymap.set("n", "<leader>pv", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })	end,
}
