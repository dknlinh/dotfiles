return {
  "mfussenegger/nvim-jdtls",
  dependencies = { "folke/which-key.nvim" },
  ft = { "java" }, -- Adjust to match Java filetypes
  config = function()
    local mason_path = vim.fn.stdpath "data" .. "/mason"
    local jdtls_path = mason_path .. "/packages/jdtls"
    local lombok_jar = jdtls_path .. "/lombok.jar"

    local config = {
      cmd = {
        vim.fn.exepath "jdtls",
        "--jvm-arg=-javaagent:" .. lombok_jar,
        "-configuration",
        vim.fn.stdpath "cache" .. "/jdtls/config",
        "-data",
        vim.fn.stdpath "cache" .. "/jdtls/workspace",
      },
      root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", "mvnw", ".git" }, { upward = true })[1]),
      settings = {
        java = {
          inlayHints = {
            parameterNames = {
              enabled = "all",
            },
          },
        },
      },
      init_options = {
        bundles = {},
      },
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    }

    -- Add debug bundles if nvim-dap and java-debug-adapter are installed
    local bundles = {}
    local java_debug_path = mason_path .. "/packages/java-debug-adapter/extension/server"
    local java_test_path = mason_path .. "/packages/java-test/extension/server"
    for _, jar in ipairs(vim.fn.glob(java_debug_path .. "/com.microsoft.java.debug.plugin-*.jar", true, true)) do
      table.insert(bundles, jar)
    end
    for _, jar in ipairs(vim.fn.glob(java_test_path .. "/*.jar", true, true)) do
      table.insert(bundles, jar)
    end
    config.init_options.bundles = bundles

    -- Start or attach JDTLS
    local function attach_jdtls()
      require("jdtls").start_or_attach(config)
    end

    -- Attach JDTLS for Java files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "java" },
      callback = attach_jdtls,
    })

    -- Set up keybindings with which-key
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "jdtls" then
          local wk = require "which-key"
          wk.add({
            { "<leader>cx", group = "extract" },
            { "<leader>cxv", require("jdtls").extract_variable_all, desc = "Extract Variable" },
            { "<leader>cxc", require("jdtls").extract_constant, desc = "Extract Constant" },
            { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
            { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
            { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
          }, { mode = "n", buffer = args.buf })
          wk.add({
            { "<leader>cx", group = "extract" },
            { "<leader>cxm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], desc = "Extract Method" },
            {
              "<leader>cxv",
              [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
              desc = "Extract Variable",
            },
            { "<leader>cxc", [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]], desc = "Extract Constant" },
          }, { mode = "v", buffer = args.buf })

          -- Set up DAP if available
          if pcall(require, "nvim-dap") then
            require("jdtls").setup_dap { hotcodereplace = "auto" }
            require("jdtls.dap").setup_dap_main_class_configs()
            wk.add({
              { "<leader>t", group = "test" },
              {
                "<leader>tt",
                function()
                  require("jdtls.dap").test_class()
                end,
                desc = "Run All Test",
              },
              {
                "<leader>tr",
                function()
                  require("jdtls.dap").test_nearest_method()
                end,
                desc = "Run Nearest Test",
              },
              { "<leader>tT", require("jdtls.dap").pick_test, desc = "Run Test" },
            }, { mode = "n", buffer = args.buf })
          end
        end
      end,
    })

    -- Attach JDTLS for the current buffer
    attach_jdtls()
  end,
}
