local keymap = vim.keymap

--keymap.set('n', 'x', '"_x')

keymap.set('i', 'jj', '<esc>')

-- Increment/decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- Delete a word backwards
keymap.set('n', 'dw', 'vb"_d')

-- Select all
-- keymap.set('n', '<C-a>', 'gg<S-v>G')

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- New tab
keymap.set('n', 'te', ':tabedit')

-- Move window
keymap.set('n', '<Space>', '<C-w>w')
keymap.set('', '<space>h', '<C-w>h')
keymap.set('', '<space>k', '<C-w>k')
keymap.set('', '<space>j', '<C-w>j')
keymap.set('', '<space>l', '<C-w>l')

-- Resize window
keymap.set('n', '<C-w><left>', '<C-w><')
keymap.set('n', '<C-w><right>', '<C-w>>')
keymap.set('n', '<C-w><up>', '<C-w>+')
keymap.set('n', '<C-w><down>', '<C-w>-')


keymap.set('n', '<bs>', '<c-^>')

keymap.set('v', '<space>y', '"+y')
