-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  {
    "mistweaverco/kulala.nvim",
    keys = {
      { "<leader>Hs", desc = "Send request" },
      { "<leader>Ha", desc = "Send all requests" },
      { "<leader>Hb", desc = "Open scratchpad" },
    },
    ft = { "http", "rest" },
    opts = {
      global_keymaps = true,
      global_keymaps_prefix = "<leader>H",
      kulala_keymaps_prefix = "",
    },
  },
}
