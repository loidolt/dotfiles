# Neovim IDE Keybindings Reference

Quick reference for all the keybindings in your comprehensive IDE setup.

## Leader Key

The leader key is `<Space>` (spacebar)

## Navigation & Movement

| Key | Description |
|-----|-------------|
| `s` | Flash jump - jump to any location |
| `S` | Flash treesitter - jump by code structure |
| `]]` | Next reference (highlighted word) |
| `[[` | Previous reference (highlighted word) |
| `<C-h/j/k/l>` | Navigate between windows |
| `<C-u>` | Scroll up (smooth) |
| `<C-d>` | Scroll down (smooth) |

## File Explorer (Neo-tree)

| Key | Description |
|-----|-------------|
| `<leader>e` | Toggle file explorer |
| `<leader>o` | Focus file explorer |

### Inside Neo-tree
| Key | Description |
|-----|-------------|
| `l` | Open file/folder |
| `h` | Close folder |
| `a` | Add file/folder |
| `d` | Delete |
| `r` | Rename |
| `c` | Copy |
| `x` | Cut |
| `p` | Paste |

## Buffer Management

| Key | Description |
|-----|-------------|
| `<S-h>` / `[b` | Previous buffer |
| `<S-l>` / `]b` | Next buffer |
| `<leader>bp` | Pin/unpin buffer |
| `<leader>bP` | Delete non-pinned buffers |
| `<leader>br` | Delete buffers to the right |
| `<leader>bl` | Delete buffers to the left |
| `<leader><leader>` | List open buffers |

## File Finding (Telescope)

| Key | Description |
|-----|-------------|
| `<leader>sf` | Search files |
| `<leader>sg` | Search by grep (text in files) |
| `<leader>sw` | Search current word |
| `<leader>sr` | Resume last search |
| `<leader>s.` | Recent files |
| `<leader>sh` | Search help |
| `<leader>sk` | Search keymaps |
| `<leader>sd` | Search diagnostics |
| `<leader>sn` | Search Neovim config files |
| `<leader>/` | Search in current buffer |

## LSP (Code Intelligence)

| Key | Description |
|-----|-------------|
| `gd` / `grd` | Go to definition |
| `grr` | Go to references |
| `gri` | Go to implementation |
| `grt` | Go to type definition |
| `grD` | Go to declaration |
| `grn` | Rename symbol |
| `gra` | Code action |
| `K` | Show hover documentation |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `<leader>f` | Format buffer |

## Diagnostics & Trouble

| Key | Description |
|-----|-------------|
| `<leader>xx` | Toggle diagnostics (Trouble) |
| `<leader>xX` | Buffer diagnostics (Trouble) |
| `<leader>cs` | Symbols (Trouble) |
| `<leader>cl` | LSP definitions/references (Trouble) |
| `<leader>xL` | Location list (Trouble) |
| `<leader>xQ` | Quickfix list (Trouble) |
| `<leader>q` | Open diagnostic quickfix list |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>tl` | Toggle inline diagnostics (lsp_lines) |

## Code Outline

| Key | Description |
|-----|-------------|
| `<leader>co` | Toggle code outline sidebar |

## Editing

| Key | Description |
|-----|-------------|
| `gcc` | Comment/uncomment line |
| `gc` (visual) | Comment/uncomment selection |
| `jk` or `kj` | Exit insert mode |
| `sa<motion><char>` | Surround add (e.g., `saiw"` surrounds word with quotes) |
| `sd<char>` | Surround delete (e.g., `sd"` removes surrounding quotes) |
| `sr<old><new>` | Surround replace (e.g., `sr"'` replaces " with ') |

## Git

| Key | Description |
|-----|-------------|
| `<leader>gd` | Open git diff view |
| `<leader>gh` | File history |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage buffer |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghR` | Reset buffer |
| `<leader>ghp` | Preview hunk inline |
| `<leader>ghb` | Blame line |
| `<leader>ghd` | Diff this |
| `]h` | Next git hunk |
| `[h` | Previous git hunk |

## Session Management

| Key | Description |
|-----|-------------|
| `<leader>qs` | Restore session for current directory |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Don't save current session |

## UI & Toggles

| Key | Description |
|-----|-------------|
| `<leader>th` | Toggle inlay hints |
| `<leader>tl` | Toggle LSP lines |
| `<leader>un` | Dismiss all notifications |
| `<leader>snh` | Show notification history |
| `<leader>snd` | Dismiss notifications |
| `<Esc>` | Clear search highlights |

## Window Management

| Key | Description |
|-----|-------------|
| `<C-h>` | Focus left window |
| `<C-j>` | Focus lower window |
| `<C-k>` | Focus upper window |
| `<C-l>` | Focus right window |
| `<C-w>s` | Split window horizontally |
| `<C-w>v` | Split window vertically |
| `<C-w>q` | Close current window |
| `<C-w>=` | Make windows equal size |

## Completion (in Insert Mode)

| Key | Description |
|-----|-------------|
| `<C-y>` | Accept completion |
| `<C-n>` / `<Down>` | Next completion item |
| `<C-p>` / `<Up>` | Previous completion item |
| `<C-space>` | Open/toggle completion menu |
| `<C-e>` | Close completion menu |
| `<C-k>` | Toggle signature help |
| `<Tab>` | Jump to next snippet field |
| `<S-Tab>` | Jump to previous snippet field |

## Terminal

| Key | Description |
|-----|-------------|
| `<Esc><Esc>` | Exit terminal mode |

## Tips

1. **Telescope** is your best friend - use `<leader>sk` to search all keymaps
2. **Which-key** shows available keybindings after you press leader
3. Use `:checkhealth` to diagnose any setup issues
4. Use `:Mason` to manage LSP servers and tools
5. Use `:Lazy` to manage plugins
6. Press `?` in any plugin window for more help

## Common Workflows

### Opening a project
1. `cd` into your project directory
2. Run `nvim`
3. Dashboard appears - press `f` to find files or `r` for recent

### Finding & editing code
1. `<leader>sf` to find files
2. `<leader>sg` to search text across all files
3. `gd` on a function/variable to go to definition
4. `grr` to see all references
5. `grn` to rename across the project

### Working with git
1. `<leader>e` to open file explorer and see changed files
2. `]h` / `[h` to navigate between changes
3. `<leader>ghp` to preview changes inline
4. `<leader>ghs` to stage hunks
5. `<leader>gd` for full diff view

### Debugging issues
1. `<leader>xx` to see all diagnostics
2. Navigate to issue location
3. `gra` for code actions to fix
4. `K` to see documentation

## Additional Resources

- Run `:Tutor` for basic Neovim tutorial
- Use `:help <topic>` to learn more about any feature
- Check out `:help telescope.nvim` for more Telescope commands
- Visit https://neovim.io/doc/ for full documentation
