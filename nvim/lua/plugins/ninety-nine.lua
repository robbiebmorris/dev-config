return {
	"ThePrimeagen/99",
	commit = "c17422457027c913c76c75a921fca1e623d2678e",
	lazy = false,
	dependencies = {
		"hrsh7th/nvim-cmp",
	},
	config = function()
		local _99 = require("99")

		local persistent_codex = setmetatable({}, {
			__index = _99.Providers.BaseProvider,
		})

		function persistent_codex._build_command(_, _, context)
			return {
				vim.fn.expand("~/.config/tmux/codex-99-submit.sh"),
				context.tmp_file .. "-prompt",
				context.tmp_file,
			}
		end

		function persistent_codex._get_provider_name()
			return "PersistentCodexProvider"
		end

		function persistent_codex._get_default_model()
			return "persistent-codex"
		end

		local tmp_root = vim.fs.joinpath(vim.env.TMPDIR or "/tmp", "nvim-99")
		local project = vim.uv.cwd() or vim.fn.getcwd()
		local tmp_dir = vim.fs.joinpath(tmp_root, vim.fn.sha256(project):sub(1, 16))

		_99.setup({
			provider = persistent_codex,
			tmp_dir = tmp_dir,
			display_errors = true,
			completion = {
				source = "cmp",
			},
			md_files = {
				"AGENTS.md",
				"AGENT.md",
			},
		})

		vim.keymap.set("v", "<leader>9v", function()
			if not vim.bo.modifiable then
				vim.notify("This diff buffer is read-only; press gf to open the working file first", vim.log.levels.WARN)
				return
			end
			_99.visual()
		end, { desc = "AI edit selection with persistent Codex" })

		vim.keymap.set("n", "<leader>9s", function()
			_99.search()
		end, { desc = "AI search with persistent Codex" })

		vim.keymap.set("n", "<leader>9o", function()
			_99.open()
		end, { desc = "Open previous 99 request" })

		vim.keymap.set("n", "<leader>9x", function()
			_99.stop_all_requests()
		end, { desc = "Stop all 99 requests" })
	end,
}
