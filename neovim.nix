# Comment here
{ pkgs, ... }:
{
  # Neovim configuration
    enable = true;
    # Disable for now as we may wish to wrap nvim.
    #defaultEditor = true;
    withNodeJs = true;
    extraConfig = ''
      if (has("termguicolors"))
        set termguicolors
      endif

      " Enable mouse support
      set mouse=a

      " Enable spell checking
      set spell

      " Show the line number plus relative line numbers
      set number
      set relativenumber

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

      " The time to wait for calling CursorHold
      set updatetime=2000

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

      colorscheme rose-pine-moon
      '';

    # Work around so that neovim can find the treesitter plugins.
    initLua = let
      parsers = pkgs.tree-sitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
    in
      ''
      -- Lua caching
      require('impatient')

      -- Ensure that treesitter shared libraries can be found.
      vim.opt.runtimepath:append("${parsers}")

      -- Configure the diagnostic symbols (nvim 0.11+)
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "🔴",
            [vim.diagnostic.severity.WARN] = "🟡",
            [vim.diagnostic.severity.INFO] = "🔵",
            [vim.diagnostic.severity.HINT] = "💡",
          },
        },
      })

      local gs = require("gitsigns")

      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        silent = true,
        border = 'rounded',
      })

      -- IDE keybindings
      vim.keymap.set('n', '<leader>ci', '<Cmd>Telescope lsp_incoming_calls<CR>', bufopts)
      vim.keymap.set('n', '<leader>co', '<Cmd>Telescope lsp_outgoing_calls<CR>', bufopts)
      vim.keymap.set('n', '<leader>d', '<Cmd>Telescope lsp_definitions<CR>', bufopts)
      vim.keymap.set('n', '<leader>i', '<Cmd>Telescope lsp_implementations<CR>', bufopts)
      vim.keymap.set('n', '<leader>g', ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", bufopts)
      vim.keymap.set('n', '<leader>o', '<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>', bufopts)
      vim.keymap.set('n', '<leader>r', '<Cmd>Telescope lsp_references<CR>', bufopts)
      vim.keymap.set('n', '<leader>f', '<Cmd>lua vim.lsp.buf.format()<CR>', bufopts)
      vim.keymap.set('n', '<leader>z', '<Cmd>lua vim.lsp.buf.rename()<CR>', bufopts)
      vim.keymap.set('n', '<leader>s', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', bufopts)
      vim.keymap.set('n', '<leader>a', '<Cmd>CodeActionMenu<CR>', bufopts)
      vim.keymap.set('n', '<leader>t', '<Cmd>TroubleToggle<CR>', bufopts)
      vim.keymap.set('n', '<leader>x', gs.reset_hunk, bufopts)
      vim.keymap.set('n', '<leader>q', '<Cmd>Telescope buffers<CR>', bufopts)
      vim.keymap.set('n', '<leader>/', '<Cmd>nohlsearch<CR>', bufopts)

      -- LSP setup using vim.lsp.config (nvim 0.11+)
      local navic = require("nvim-navic")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- Hack around the fact that null-ls defaults to utf-16 for some reason,
      -- and so we will get annoying complaints about the encoding type.
      capabilities.offsetEncoding = { 'utf-16' }

      -- pyright setup
      vim.lsp.enable('pyright')

      -- bashls setup
      vim.lsp.enable('bashls')

      -- clangd setup
      vim.lsp.config('clangd', {
        cmd = {
         "clangd",
         "--all-scopes-completion",
         "--recovery-ast",
         "--clang-tidy",
         "--background-index",
         "--background-index-priority=normal",
         "-j=64",
         "--cross-file-rename",
         "--suggest-missing-includes",
         "--enable-config"
        },
        capabilities = capabilities,
        root_markers = { "compile_commands.json", ".clangd", ".git" },
        init_options = {
          clangdFileStatus = true,
          usePlaceholders = true,
          completeUnimported = true,
          semanticHighlighting = true,
        },
        filetypes = { "c", "cpp", "hpp", "h"}
      })
      vim.lsp.enable('clangd')

      -- nixd setup
      local nixd_capabilities = vim.lsp.protocol.make_client_capabilities()
      nixd_capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }
      vim.lsp.config('nixd', { capabilities = nixd_capabilities })
      vim.lsp.enable('nixd')

      -- rust-analyzer setup
      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = { command = "clippy" },
            rustfmt = { extraArgs = {} },
          },
        },
      })
      vim.lsp.enable('rust_analyzer')

      -- jsonls setup
      vim.lsp.config('jsonls', {
        capabilities = capabilities,
      })
      vim.lsp.enable('jsonls')

      -- yamlls setup
      vim.lsp.config('yamlls', {
        capabilities = capabilities,
      })
      vim.lsp.enable('yamlls')

      -- taplo (TOML) setup
      vim.lsp.config('taplo', {
        capabilities = capabilities,
      })
      vim.lsp.enable('taplo')

      -- buf_ls (Protobuf) setup
      vim.lsp.config('buf_ls', {
        capabilities = capabilities,
      })
      vim.lsp.enable('buf_ls')

      -- sqls setup
      vim.lsp.config('sqls', {
        capabilities = capabilities,
      })
      vim.lsp.enable('sqls')

      -- Disable formatting for all LSPs except nixd and rust_analyzer
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client == nil then return end
          if client.name ~= 'nixd' and client.name ~= 'rust_analyzer' then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end
        end,
      })

      -- LspAttach autocmd for on_attach functionality
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client == nil then return end

          -- Attach navic for clangd and rust_analyzer
          if client.name == 'clangd' or client.name == 'rust_analyzer' then
            navic.attach(client, args.buf)
          end

          -- CursorHold diagnostic float for nixd
          if client.name == 'nixd' then
            vim.api.nvim_create_autocmd("CursorHold", {
              buffer = args.buf,
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
          end
        end,
      })

      -- nil setup
      --[[
      local lsp_path = '${pkgs.nil}/bin/nil'
      require('lspconfig').nil_ls.setup {
        autostart = true,
        capabilities = caps,
       cmd = { lsp_path },
        settings = {
          ['nil'] = {
            testSetting = 42,
            formatting = {
              command = { "nixpkgs-fmt" },
            },
          },
        },
       }
      ]]--

     -- Status bar configuration
     require('lualine').setup {
       options = {
         theme = "rose-pine",
         globalstatus = true
       },
       sections = {
         lualine_x = {
           {
             require("noice").api.status.mode.get,
             cond = require("noice").api.status.mode.has,
             color = { fg = "#ff9e64" },
           },
           {
             require("noice").api.status.command.get,
             cond = require("noice").api.status.command.has,
           },
         },
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

    plugins =
    (with pkgs.unstable.vimPlugins; [
     # None yet
    ]) ++ (with pkgs.vimPlugins; [
      # Screenkey for prominent keystroke display
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          name = "screenkey-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "NStefan002";
            repo = "screenkey.nvim";
            rev = "v2.4.2";
            sha256 = "sha256-EGyIkWcQbCurkBbeHpXvQAKRTovUiNx1xqtXmQba8Gg=";
          };
        };
        type = "lua";
        config = ''
          require("screenkey").setup({
            win_opts = {
              row = 1,
              col = vim.o.columns / 2,
              relative = "editor",
              anchor = "NE",
              width = 40,
              height = 1,
              border = "rounded",
            },
            clear_after = 3,
            group_mappings = true,
          })
        '';
      }
      # Noice UI and dependencies
      nui-nvim
      nvim-notify
      {
        plugin = noice-nvim;
        type = "lua";
        config = ''
          require("noice").setup({
            lsp = {
              override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
              },
            },
            presets = {
              bottom_search = true,
              command_palette = true,
              long_message_to_split = true,
              lsp_doc_border = true,
            },
            routes = {
              { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
              { view = "split", filter = { event = "msg_show", min_height = 20 } },
            },
          })

          -- LSP hover doc scrolling
          vim.keymap.set({ "n", "i", "s" }, "<c-f>", function()
            if not require("noice.lsp").scroll(4) then return "<c-f>" end
          end, { silent = true, expr = true })
          vim.keymap.set({ "n", "i", "s" }, "<c-b>", function()
            if not require("noice.lsp").scroll(-4) then return "<c-b>" end
          end, { silent = true, expr = true })

          -- Dismiss notifications
          vim.keymap.set("n", "<leader>nd", "<cmd>Noice dismiss<cr>", { desc = "Dismiss notifications" })
        '';
      }
      camelcasemotion
      vim-easymotion
      vim-highlightedyank
      rose-pine
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
      lspkind-nvim
      # Completion
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local lspkind = require('lspkind')
          local cmp = require('cmp')
          cmp.setup({
            mapping = cmp.mapping.preset.insert({
              ['<C-Tab>'] = cmp.mapping.complete(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
            formatting = {
              format = lspkind.cmp_format({
                mode = 'symbol_text',
                menu = ({
                  buffer = "[Buffer]",
                  nvim_lsp = "[LSP]",
                  luasnip = "[LuaSnip]",
                  path = "[Path]",
                  fish = "[fish]",
                }),
                maxwidth = 50,
                ellipsis_char = '...', 
                before = function (entry, vim_item)
                  return vim_item
                end
              })
            },
            snippet = {
              expand = function(args)
                require("luasnip").lsp_expand(args.body)
              end,
            },
            enabled = function()
              -- Disable some completion in comments and string literals. 
              -- This is essential for avoiding annoying completions when
              -- trying to write normal text.
              local context = require 'cmp.config.context'
              -- Keep command mode completion enabled
              if vim.api.nvim_get_mode().mode == 'c' then
                return true
              else
                -- TODO Abstract out duplicated code?
                return not context.in_treesitter_capture("comment")
                   and not context.in_syntax_group("Comment")
                   and not context.in_treesitter_capture("string")
                   and not context.in_syntax_group("String")
              end
            end,
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
      telescope-live-grep-args-nvim
      telescope-lsp-handlers-nvim
      {
        plugin = fidget-nvim;
        type = "lua";
        config = ''
          require("fidget").setup({})
        '';
      }
      {
        plugin = lsp_signature-nvim;
        type = "lua";
        config = ''
          local cfg = {}
          require "lsp_signature".setup(cfg)
        '';
      }
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
        plugin = none-ls-nvim;
        type = "lua";
        config = ''
          local null_ls = require("null-ls")
          null_ls.setup({
              debug = false;
              sources = {
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
      # Allow opening in existing session
      neovim-remote

      # Python
      (python3.withPackages (ps: with ps; [
        setuptools # Required by pylama for some reason
        pylama
        black
        isort
        yamllint
        debugpy
      ]))
      pyright

      # Essentials
      # nodePackages.npm
      # nodePackages.neovim

      # Nix
      statix
      nixpkgs-fmt
      nixd
      #nil

      # C, C++
      clang-tools
      #cppcheck

      # Rust
      rust-analyzer

      # Shell scripting
      nodePackages.bash-language-server

      # JSON
      nodePackages.vscode-langservers-extracted

      # YAML (included in vscode-langservers-extracted, but explicit for clarity)
      yaml-language-server

      # TOML
      taplo

      # Protobuf
      buf

      # SQL
      sqls

      # Additional
      codespell
      gitlint

      # Telescope dependencies
      ripgrep
      fd
    ];
}
