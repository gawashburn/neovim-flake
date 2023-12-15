# Comment here
{ pkgs, ... }:
{
  # Neovim configuration
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    extraConfig = ''
      if (has("termguicolors"))
        set termguicolors
      endif

      " Enable mouse support
      set mouse=a

      " Enable spell checking
      set spell

      " Show line numbers
      set number

      " Highlight the line where cursor is located
      set cursorline

      " Highlight the recommend file width
      set colorcolumn=80

      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
      set expandtab

      set autoindent
      set backspace=indent,eol,start

      set encoding=utf-8

      set list
      "set listchars=space:⋅,trail:⋅,tab:→\ ,eol:¬
      set listchars=trail:⋅,tab:→\ ,eol:¬

      set ignorecase
      set smartcase
      set incsearch
      set showmatch
      set hlsearch
      set gdefault

      set wrap
      set textwidth=72
      set formatoptions=qrn1

      set matchpairs+=<:>

      "Change the leader key
      let mapleader=","

      " Disable macro recording.
      noremap q <nop>

      " Set up the clipboard to use rpbcopy so that yanking will
      " propagate to my local clipboard.
      let g:clipboard = {
        \   'name': 'myClipboard',
        \   'copy': {
        \      '+': 'rpbcopy',
        \      '*': 'rpbcopy',
        \   },
        "\   'paste': {
        "\      '+': '+',
        "\      '*': '*',
        "\   },
        \   'cache_enabled': 0,
        \ }

      set clipboard+=unnamedplus

      let g:camelcasemotion_key = '<leader>'

      " Fix this should be moved to a per host configuration.
      let g:oceanic_next_terminal_bold = 1
      let g:oceanic_next_terminal_italic = 1
      colorscheme OceanicNext
      '';

    # Work around so that neovim can find the treesitter plugins.
    extraLuaConfig = let
      parsers = pkgs.tree-sitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
    in
      ''
      -- Lua caching
      require('impatient')

      -- Ensure that treesitter shared libraries can be found.
      vim.opt.runtimepath:append("${parsers}")

      -- Configure the diagnostic symbols
      vim.cmd [[ 
        sign define DiagnosticSignError text=  linehl= texthl=DiagnosticSignError numhl= 
        sign define DiagnosticSignWarn text= linehl= texthl=DiagnosticSignWarn numhl= 
        sign define DiagnosticSignInfo text=  linehl= texthl=DiagnosticSignInfo numhl= 
        sign define DiagnosticSignHint text=💡  linehl= texthl=DiagnosticSignHint numhl= 
      ]]

      local gs = require("gitsigns")

      -- IDE keybindings
      vim.keymap.set('n', '<leader>z', '<Cmd>Telescope buffers<CR>', bufopts)
      vim.keymap.set('n', '<leader>h', '<Cmd>lua vim.lsp.buf.hover()<CR>', bufopts)
      vim.keymap.set('n', '<leader>d', '<Cmd>lua vim.lsp.buf.declaration()<CR>', bufopts)
      vim.keymap.set('n', '<leader>i', '<Cmd>lua vim.lsp.buf.definition()<CR>', bufopts)
      vim.keymap.set('n', '<leader>g', '<Cmd>Telescope live_grep<CR>', bufopts)
      vim.keymap.set('n', '<leader>o', '<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>', bufopts)
      vim.keymap.set('n', '<leader>r', '<Cmd>Telescope lsp_references<CR>', bufopts)
      vim.keymap.set('n', '<leader>f', '<Cmd>lua vim.lsp.buf.format()<CR>', bufopts)
      vim.keymap.set('n', '<leader>s', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', bufopts)
      vim.keymap.set('n', '<leader>a', '<Cmd>CodeActionMenu<CR>', bufopts)
      vim.keymap.set('n', '<leader>t', '<Cmd>TroubleToggle<CR>', bufopts)
      vim.keymap.set('n', '<leader>x', gs.reset_hunk, bufopts)

      -- Clangd setup
      local navic = require("nvim-navic")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local clangd_ext_handler = require("lsp-status").extensions.clangd.setup()
      require('lspconfig')['clangd'].setup {
        cmd = {
         "clangd",
         "--compile-commands-dir=/local/home/washbug/padb",
         "--all-scopes-completion",
         "--recovery-ast",
         "--clang-tidy",
         "--background-index",
         "-j=64",
         "--log=verbose",
         "--cross-file-rename",
         "--suggest-missing-includes",
         "--enable-config"
        },
        on_attach = function(client, bufnr)
         navic.attach(client, bufnr)
        end,
        capabilities = capabilities,
        init_options = {
          clangdFileStatus = true, -- Provides information about activity on clangd’s per-file worker thread
          usePlaceholders = true,
          completeUnimported = true,
          semanticHighlighting = true,
        },
        handlers = clangd_ext_handler,
        filetypes = { "c", "cpp", "hpp", "h"}
      }

      local nvim_lsp = require("lspconfig")

      -- Add additional capabilities supported by nvim-cmp
      -- nvim hasn't added foldingRange to default capabilities, users must add it manually
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.foldingRange = {
      	dynamicRegistration = false,
      	lineFoldingOnly = true,
      }

      -- nixd setup
      nvim_lsp.nixd.setup({
      	on_attach = function(bufnr)
          vim.api.nvim_create_autocmd("CursorHold", {
        		buffer = bufnr,
        		callback = function()
        			local opts = {
        				focusable = false,
        				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        				border = "rounded",
        				source = "always",
        				prefix = " ",
        				scope = "line",
        			}
        			vim.diagnostic.open_float(nil, opts)
        		end,
        	})
        end,
      	capabilities = capabilities,
      })

      -- nil setup
      --local lsp_path = '${pkgs.nil}/bin/nil'
      --require('lspconfig').nil_ls.setup {
      --  autostart = true,
      --  capabilities = caps,
      -- cmd = { lsp_path },
      --  settings = {
      --    ['nil'] = {
      --      testSetting = 42,
      --      formatting = {
      --        command = { "nixpkgs-fmt" },
      --      },
      --    },
      --  },
      -- }

     -- Status bar configuration
     require('lualine').setup {
       options = {
         theme = "OceanicNext",
         globalstatus = true
       },
       winbar = {
         lualine_a = { function ()
           if navic.is_available() then
             local location = navic.get_location()
               if location ~= "" then
                 return location
               else
                 return "..."
               end
           end
           return ""
         end},
         lualine_b = {},
         lualine_c = {},
         lualine_x = { 'lsp_progress' },
         lualine_y = {},
         lualine_z = {},
       },
       inactive_winbar = {
         lualine_a = {},
       }
     }

     -- Use internal formatting for bindings like gq.
     vim.api.nvim_create_autocmd('LspAttach', { 
       callback = function(args) 
         vim.bo[args.buf].formatexpr = nil 
       end, 
     })

    '';

    plugins = (with pkgs.unstable.vimPlugins; [
     # None yet
    ]) ++ (with pkgs.vimPlugins; [
      camelcasemotion
      vim-easymotion
      vim-highlightedyank
      oceanic-next
      lsp-colors-nvim
      nvim-treesitter.withAllGrammars
      # Comment/uncomment helper
      {
        plugin = comment-nvim;
        type = "lua";
        config = ''
          require('Comment').setup()
        '';
      }
      # Completion
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require('cmp')
          cmp.setup({
            mapping = cmp.mapping.preset.insert({
              ['<C-Tab>'] = cmp.mapping.complete(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
          	snippet = {
          		expand = function(args)
          			require("luasnip").lsp_expand(args.body)
	          	end,
	          },
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = "luasnip" },
              { name = 'fish' },
              { name = 'path' }
             })
          })
        '';
      }
      cmp-path
      cmp-nvim-lsp
      nvim-lspconfig
      vim-yaml
      vim-fish
      cmp-fish
      cmp-buffer
      cmp_luasnip
      plenary-nvim
      telescope-nvim
      telescope-lsp-handlers-nvim
      lsp-status-nvim
      lsp_signature-nvim
      vim-codefmt
      nvim-web-devicons
      # git integration
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup {
            current_line_blame = true,
            current_line_blame_opts = {
              virt_text = true,
              virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
                delay = 1000,
              ignore_whitespace = false,
            }
          }

          on_attach = function(bufnr)
          end
        '';
      }
      impatient-nvim
      # High performance highlighter
      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = ''
          require('colorizer').setup {
          }
        '';
      }
      # Tab bar
      {
        plugin = barbar-nvim;
        type = "lua";
        config = ''
          require('bufferline').setup()
        '';
      }
      lualine-nvim
      lualine-lsp-progress
      nvim-navic
      nvim-dap
      nvim-dap-ui
      nvim-code-action-menu
      gruvbox-nvim
      diffview-nvim
      # Indentation visuals
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = ''
          require("ibl").setup {
          }
        '';
      }
      friendly-snippets
      # Snippet engine
      {
        plugin = luasnip;
        type = "lua";
        config = ''
          local luasnip = require("luasnip")
          luasnip.setup({
	          region_check_events = "CursorMoved",
          })
          -- Friendly snippets
          require("luasnip.loaders.from_vscode").lazy_load()
        '';
      }
      # Helpful diagnostic summary
      {
        plugin = trouble-nvim;
        type = "lua";
        config = ''
          require("trouble").setup {
          }
        '';
      }
      # Language server support.  Without the server.
      {
        plugin = null-ls-nvim;
        type = "lua";
        config = ''
          local null_ls = require("null-ls")
          null_ls.setup({
              debug = false;
              sources = {
              -- Shell
              null_ls.builtins.formatting.shfmt,
              null_ls.builtins.formatting.shellharden,
              null_ls.builtins.diagnostics.shellcheck,
              null_ls.builtins.code_actions.shellcheck,

              -- C/C++
              null_ls.builtins.diagnostics.cppcheck,

              -- Spelling
              -- null_ls.builtins.completion.spell,
              null_ls.builtins.diagnostics.codespell.with({
                  args = { "--builtin", "clear,rare,code", "-" },
                  }),

              -- Nix
              null_ls.builtins.diagnostics.statix,
              null_ls.builtins.code_actions.statix,
              null_ls.builtins.formatting.nixpkgs_fmt,

              -- Git
                null_ls.builtins.code_actions.gitsigns,
              null_ls.builtins.diagnostics.gitlint,

              null_ls.builtins.diagnostics.actionlint,
              }
          })
        '';
      }
    ]);
    extraPackages = with pkgs; [
      # Essentials
      nodePackages.npm
      nodePackages.neovim

      # Nix
      statix
      nixpkgs-fmt
      nixd
      #nil

      # C, C++
      clang-tools
      cppcheck

      # Shell scripting
      shfmt
      shellcheck
      shellharden

      # Additional
      nodePackages.bash-language-server
      nodePackages.yaml-language-server
      codespell
      gitlint

      # Telescope dependencies
      ripgrep
      fd
    ];
}
