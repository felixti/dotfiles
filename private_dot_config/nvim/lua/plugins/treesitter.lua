-- Neovim 0.12.0 + nvim-treesitter main branch compatible configuration
-- Uses native Neovim APIs instead of the removed nvim-treesitter.configs module

---@type LazySpec
return {
  -- Main nvim-treesitter configuration
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      local languages = {
        "bash", "c", "css", "dockerfile", "gitignore",
        "html", "javascript", "jsdoc", "json", "lua",
        "luadoc", "luap", "markdown", "markdown_inline",
        "python", "query", "regex", "toml", "tsx",
        "typescript", "vim", "vimdoc", "yaml",
      }

      -- Install parsers asynchronously (replaces ensure_installed)
      require("nvim-treesitter").install(languages)

      -- Setup treesitter features for each buffer
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter.setup", {}),
        callback = function(args)
          local buf = args.buf
          local filetype = args.match

          -- Check if parser exists for this language
          local language = vim.treesitter.language.get_lang(filetype) or filetype
          if not vim.treesitter.language.add(language) then
            return
          end

          -- Enable treesitter highlight
          vim.treesitter.start(buf, language)

          -- Enable treesitter folds
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
      })

      -- Register language aliases
      vim.treesitter.language.register("c_sharp", { "csharp", "c_sharp" })
    end,
  },
  -- Disable plugins that depend on old nvim-treesitter.configs API
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = false,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = false,
  },
  {
    "nvim-treesitter/nvim-treesitter-refactor",
    enabled = false,
  },
  {
    "nvim-treesitter/playground",
    enabled = false,
  },
  {
    "windwp/nvim-ts-autotag",
    enabled = false,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    enabled = false,
  },
  -- aerial.nvim is now enabled with the latest version (3.1.0) which has Neovim 0.12 fixes
}
