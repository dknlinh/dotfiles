return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("catppuccin").setup {
        transparent_background = true,
        integrations = {
          neotree = true,
        },
      }
      vim.cmd.colorscheme "catppuccin-mocha"
    end,
  },
}
