return {
	"sindrets/diffview.nvim",
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewFileHistory",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
	},
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff view" },
		{ "<leader>gD", "<cmd>DiffviewOpen HEAD~1..HEAD<cr>", desc = "Git previous commit diff" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git file history" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Git repository history" },
		{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Git diff view" },
	},
	opts = {
		use_icons = false,
	},
}
