-- Neovim 0.12.0 + nvim-treesitter main branch configuration
-- REQUIRED for compatibility with Neovim 0.12's new iter_matches() API
-- See: https://github.com/nvim-treesitter/nvim-treesitter/issues/7926

---@type LazySpec
return {
  -- Main nvim-treesitter configuration - MUST use main branch for Neovim 0.12
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- Configure nvim-treesitter (main branch API)
      local ok, ts = pcall(require, "nvim-treesitter")
      if not ok then
        vim.notify("Failed to load nvim-treesitter", vim.log.levels.ERROR)
        return
      end

      -- Setup install directory
      ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      -- Install parsers - main branch uses async installation
      local languages = {
        "bash", "c", "css", "dockerfile", "gitignore",
        "html", "javascript", "jsdoc", "json", "lua",
        "luadoc", "luap", "markdown", "markdown_inline",
        "python", "query", "regex", "toml", "tsx",
        "typescript", "vim", "vimdoc", "yaml",
      }

      -- Install parsers
      ts.install(languages)

      -- Enable treesitter highlighting via Neovim's native API
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter.highlight", { clear = true }),
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      -- Register language aliases
      pcall(vim.treesitter.language.register, "c_sharp", { "csharp", "c_sharp" })
    end,
  },

  -- Aerial.nvim - requires nvim-treesitter main branch for Neovim 0.12
  -- IMPORTANT: The aerial treesitter backend has been patched for Neovim 0.12
  -- Located at: ~/.local/share/nvim/lazy/aerial.nvim/lua/aerial/backends/treesitter/init.lua
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        max_width = { 40, 0.2 },
        width = nil,
        min_width = 10,
      },
      show_guides = true,
    },
  },

  -- Disable plugins incompatible with nvim-treesitter main branch
  { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
  { "nvim-treesitter/nvim-treesitter-context", enabled = false },
  { "nvim-treesitter/nvim-treesitter-refactor", enabled = false },
  { "nvim-treesitter/playground", enabled = false },
  { "windwp/nvim-ts-autotag", enabled = false },
  { "JoosepAlviste/nvim-ts-context-commentstring", enabled = false },
}
