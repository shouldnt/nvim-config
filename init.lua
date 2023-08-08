-- todo: find all and Replace
-- todo: stand alone git window for git stuff

-- options
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- command

-- auto command
-- vim.api.nvim_create_autocmd({"InsertEnter"}, {
--   command = "highlight CursorLine guibg=#000050 guifg=fg ctermbg=LightBlue",
-- })
-- 
-- vim.api.nvim_create_autocmd({"InsertLeave"}, {
--   command = "highlight CursorLine guibg=#004000 guifg=fg ctermbg=Blue",
-- })

-- key mappings
vim.keymap.set('i', "jj", "<esc>", {noremap = true});
vim.keymap.set('n', "'", "`", {noremap = true});
vim.keymap.set('n', "`", "'", {noremap = true});
vim.keymap.set('n', "<BS>", "<c-6>", {noremap = true});
vim.keymap.set('n', "<space>/", ":noh<cr>", {noremap = true});

-- plugins config
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	-- My plugins here
	use "williamboman/mason.nvim"
	use "williamboman/mason-lspconfig.nvim"
	use "neovim/nvim-lspconfig"

	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/cmp-cmdline'
	use 'hrsh7th/nvim-cmp'

	-- For vsnip users.
	use 'hrsh7th/cmp-vsnip'
	use 'hrsh7th/vim-vsnip'

	-- note: should install ripgrep binary for faster fuzzy search
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.2',
		-- or                            , branch = '0.1.x',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

	-- this require fzf binary
	use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

	use 'nvim-treesitter/nvim-treesitter'
	-- this plugin will fix jsx indent
	use 'maxmellon/vim-jsx-pretty'
	use {
		"windwp/nvim-autopairs",
		config = function() require("nvim-autopairs").setup {} end
	}
	-- auto detect indent
	use "tpope/vim-sleuth"
	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'nvim-tree/nvim-web-devicons', opt = true }
	}
	-- colorscheme
	use { "catppuccin/nvim", as = "catppuccin" }
	-- code comment
	use 'numToStr/Comment.nvim'
	use "JoosepAlviste/nvim-ts-context-commentstring"

	-- git plugin
	use "tpope/vim-fugitive"
	
	use "nvim-tree/nvim-tree.lua"
	-- terminal inside neovim
	use "akinsho/toggleterm.nvim"

	use "nvim-treesitter/nvim-treesitter-context"

	use 'sindrets/diffview.nvim'

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require('packer').sync()
	end
end)

require("mason").setup()
require("mason-lspconfig").setup()

-- comp config
local cmp = require'cmp'

cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		['<Tab>'] = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
				-- elseif luasnip.expand_or_jumpable() then
				-- 	luasnip.expand_or_jump()
			else
				fallback()
			end
		end,
		['<S-Tab>'] = function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
				-- elseif luasnip.jumpable(-1) then
				-- 	luasnip.jump(-1)
			else
				fallback()
			end
		end,
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' }, -- For vsnip users.
		-- { name = 'luasnip' }, -- For luasnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
		}, {
			{ name = 'buffer' },
	})
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
		{ name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
		}, {
			{ name = 'buffer' },
	})
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
		}, {
			{ name = 'cmdline' }
	})
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
require('lspconfig')['tsserver'].setup {
	capabilities = capabilities
}
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end, opts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<space>f', function()
			vim.lsp.buf.format { async = true }
			end, opts)
	end,
})
--end comp config

-- telescope config

require('telescope').setup{
	defaults = {
		file_ignore_patterns = {
			"node_modules"
		}
	}
}
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')
function findNoIgnore(func) 
	return function() 
		func({no_ignore = true});
	end
end
vim.keymap.set('n', '<space>ff', findNoIgnore(builtin.find_files), {})
vim.keymap.set('n', '<c-p>', findNoIgnore(builtin.find_files), {})
vim.keymap.set('i', '<c-p>', findNoIgnore(builtin.find_files), {})
vim.keymap.set('n', '<space>fg', builtin.live_grep, {})
vim.keymap.set('n', '<space>fb', builtin.buffers, {})
vim.keymap.set('n', '<space>fh', builtin.help_tags, {})
--end telescope config
--
--
-- tree-sitter config
require'nvim-treesitter.configs'.setup {
	context_commentstring = {
		enable = true,
	},
	indent = {
		enable = true
	},
	highlight = {
		enable = true,
	},
	ensure_installed = {
		'javascript',
		'typescript',
		'css',
		'scss',
		'html'
	}
}
--end tree-sitter config

-- lualine
require('lualine').setup()
--end lualine
--
--colorscheme
vim.cmd.colorscheme "catppuccin"

-- code comment setup
require('Comment').setup()

-- nvim tree (file explorer)
require("nvim-tree").setup({
	update_focused_file = {
		enable = true,
		update_root = false,
		ignore_list = {"node_modules"},
	},
})
vim.keymap.set('n', '<space>e', ':NvimTreeOpen<cr>', {silent=true})

-- terminal inside neovim
require("toggleterm").setup()
function _G.set_terminal_keymaps()
	local opts = {buffer = 0}
	vim.keymap.set('t', '<C-`><C-`>', [[ToggleTerm direction=horizontal<CR>]], opts)
	vim.keymap.set('t', '<C-`><C-1>', [[2ToggleTerm direction=horizontal<CR>]], opts)
	vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
	vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
	vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
	vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
	vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
	vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
	vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://toggleterm instead
vim.cmd('autocmd! TermOpen term:// lua set_terminal_keymaps()')

-- neovide config
if vim.g.neovide then
	vim.g.neovide_window_title = vim.loop.cwd();
	vim.g.neovide_cursor_vfx_mode = "railgun"
	vim.g.neovide_cursor_vfx_particle_lifetime = 0.5
	vim.g.neovide_cursor_vfx_particle_phase = 4.5
	vim.g.neovide_cursor_vfx_particle_speed = 50.0
	vim.g.neovide_cursor_vfx_particle_density = 10
	vim.opt.guifont = { "Hack NFM", ":h11" }
end

-- nvim treesitter context 
require'treesitter-context'.setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}
