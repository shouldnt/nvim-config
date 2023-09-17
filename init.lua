-- todo: find all and Replace
-- todo: stand alone git window for git stuff

-- options
vim.opt.wrap = false
vim.opt.number = true
vim.opt.swapfile = true
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
vim.keymap.set('n', "`", "<nop>", {noremap = true});
vim.keymap.set('n', "<BS>", "<c-6>", {noremap = true});
vim.keymap.set('n', "<space>/", ":noh<cr>", {noremap = true});
vim.keymap.set('n', "<space>p", '"+[p', {noremap = true});
vim.keymap.set('n', "<space>y", '"+y', {noremap = true});
vim.keymap.set('v', "<space>y", '"+y', {noremap = true});
vim.keymap.set('i', "<c-v>", '<esc>"+[p', {noremap = true});

--fine-grain undo
local undoBreaks = {"<space>", ",", '.', ';', ':', '(', ')', '{', '}'}

for key,value in ipairs(undoBreaks) 
do
	vim.keymap.set('i', value, value .. '<c-g>u');
end

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
	use 'nvimdev/lspsaga.nvim'
	use "williamboman/mason.nvim"
	use "williamboman/mason-lspconfig.nvim"
	use "neovim/nvim-lspconfig"

	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/cmp-cmdline'
	use 'hrsh7th/nvim-cmp'

	use "lukas-reineke/lsp-format.nvim"

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
	use { 'nvim-tree/nvim-web-devicons' }
	use {
		'nvim-lualine/lualine.nvim',
	}
	-- colorscheme
	use { "catppuccin/nvim", as = "catppuccin" }
	-- code comment
	use 'numToStr/Comment.nvim'
	-- use "JoosepAlviste/nvim-ts-context-commentstring"

	-- git plugin
	use "tpope/vim-fugitive"

	use "nvim-tree/nvim-tree.lua"
	-- terminal inside neovim
	use "akinsho/toggleterm.nvim"

	-- use "nvim-treesitter/nvim-treesitter-context"

	use 'sindrets/diffview.nvim'

	use 'mbbill/undotree'	

	use {
		'stevearc/oil.nvim'
	}

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
require("lsp-format").setup {}
local on_attach = function(client)
	require("lsp-format").on_attach(client)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
local prettier = {
    formatCommand = [[prettier --stdin-filepath ${INPUT} ${--tab-width:tab_width}]],
    formatStdin = true,
}
require('lspconfig')['tsserver'].setup {
	capabilities = capabilities,
	on_attach = on_attach,
	init_options = { documentFormatting = true },
    settings = {
        languages = {
            typescript = { prettier },
            javascript = { prettier },
        },
    },
}
require('lspconfig')['jsonls'].setup {
	capabilities = capabilities,
	on_attach = on_attach,
}
require('lspconfig')['eslint'].setup {
	capabilities = capabilities,
}
require('lspconfig')['cssls'].setup {
	capabilities = capabilities,
}
require('lspconfig')['emmet_ls'].setup {
	capabilities = capabilities,
}
require('lspconfig')['tailwindcss'].setup {
	capabilities = capabilities,
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
--
--diagnostic config
vim.diagnostic.config({
	virtual_text = true,
	float = {
		show_header = false,
		format = function(diagnostic)
			print(diagnostic)
			return string.format('%s\n%s: %s', diagnostic.message, diagnostic.source, diagnostic.code)
		end,
	},
})

--end diagnostic config

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
	filters = {
		git_ignored = false
	}
})
vim.keymap.set('n', '<space>e', ':NvimTreeOpen<cr>', {silent=true})

-- terminal inside neovim
require("toggleterm").setup()

vim.keymap.set('n', '``', function()
	vim.cmd [[ToggleTerm direction=horizontal]]
end, { noremap = true	})
vim.keymap.set('n', '`1', function()
	vim.cmd [[1ToggleTerm direction=horizontal]]
end, { noremap = true	})
vim.keymap.set('n', '`2', function()
	vim.cmd [[2ToggleTerm direction=horizontal]]
end, { silent = true, noremap = true	})

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

-- lsp saga setup
require('lspsaga').setup({})
vim.keymap.set('n', '[e', '<cmd>Lspsaga diagnostic_jump_next<cr>')
vim.keymap.set('n', ']e', '<cmd>Lspsaga diagnostic_jump_prev<cr>')

-- oil nvim
require('oil').setup()
