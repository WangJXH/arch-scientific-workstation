echo "MY VIMRC LOADED"
set hidden
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
nmap <F8> :TagbarToggle<CR>
nmap <F7> :NERDTree<CR>

nnoremap <leader>gs :Git<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gl :Git log --oneline<CR>
nnoremap <leader>gp :Git push<CR>


" Use clang-format-14 on save for C/C++ files
" autocmd BufWritePre *.c,*.cpp,*.h,*.hpp,*.cc,*.cxx silent! %!clang-format-14

" ============================================================
" Core
" ============================================================
set nocompatible
set encoding=utf-8
set fileencoding=utf-8
filetype plugin indent on       " was 'filetype off' — this fixes VimTeX
syntax on

" ============================================================
" UI
" ============================================================
" colorscheme pablo
" set relativenumber number
" set cursorline
" set textwidth=100               " bumped from 80 for LaTeX
" set spelllang=en_us
" set conceallevel=1

" set termguicolors

" highlight Statement  guifg=#569CD6 ctermfg=75
" highlight Type       guifg=#4EC9B0 ctermfg=43
" highlight Identifier guifg=#9CDCFE ctermfg=117

set relativenumber
set number
set textwidth=100
set spelllang=en_us
set conceallevel=1
set concealcursor=nc
" ============================================================
" LaTeX / VimTeX
" ============================================================
" autocmd FileType tex setlocal textwidth=100
set concealcursor=nc

" Format on save for LaTeX files
let $LANG = 'C.UTF-8'
let $LC_ALL = 'C.UTF-8'
autocmd BufWritePre *.tex
      \ let save_cursor = getpos(".") |
      \ silent execute ':%!latexindent -l' |
      \ call setpos('.', save_cursor)

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'rhysd/vim-clang-format'
" Use clang-format-14
" let g:clang_format#command = 'clang-format-14'

let g:clang_format#command = '/usr/bin/clang-format'

" Format on save for C/C++ files
autocmd BufWritePre *.c,*.cc,*.cpp,*.h,*.hpp ClangFormat
nmap <silent> <F3> :ClangFormat<CR>
vmap <silent> <F3> :ClangFormat<CR>

Plugin 'airblade/vim-rooter'
" Always set project root globally, not per-window
let g:rooter_cd_cmd = 'cd'

" Project markers
let g:rooter_patterns = ['.git'] 
let g:rooter_silent_chdir = 0

Plugin 'tpope/vim-dispatch'

nnoremap <F5> :Dispatch cmake --build build<CR>

" ctags -R --languages=C++ --exclude=.git --exclude=build
" Use Universal Ctags everywhere
if executable('ctags')
  let g:tagbar_ctags_bin = exepath('ctags')
  let g:gutentags_ctags_executable = exepath('ctags')
else
  let g:gutentags_enabled = 0
endif

let g:gutentags_project_root = ['.git', 'CMakeLists.txt']
let g:gutentags_ctags_extra_args = ['--languages=C++', '--exclude=.git', '--exclude=build']
let g:gutentags_cache_dir = expand('~/.cache/tags')

let g:gutentags_trace = 0
let g:gutentags_verbose = 0
let g:gutentags_silent = 1
Plugin 'ludovicchabant/vim-gutentags'

Plugin 'christoomey/vim-tmux-navigator'
Plugin 'preservim/tagbar'
Plugin 'preservim/nerdtree'
Plugin 'tpope/vim-commentary'
autocmd FileType c,cpp setlocal commentstring=//\ %s
Plugin 'tpope/vim-fugitive'
Plugin 'ctrlpvim/ctrlp.vim'
" Ignore build directories in CtrlP
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](build(-.*)?|cmake-build.*|_build)$',
  \ 'file': '\v\.(o|obj|so|a|out|d)$'
  \ }

Plugin 'lervag/vimtex'
" cd ~/.vim/bundle/vimtex
" git fetch --tags
" git checkout v2.15
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
let g:tex_conceal='abdmg'
let g:vimtex_toc_config = {
\ 'name' : 'TOC',
\ 'layers' : ['content', 'todo', 'include'],
\ 'split_width' : 25,
\ 'todo_sorted' : 0,
\ 'show_help' : 1,
\ 'show_numbers' : 1,
\}

" Track the engine.
Plugin 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'

" Trigger configuration. You need to change this to something other than <tab> if you use one of the following:
" - https://github.com/Valloric/YouCompleteMe
" - https://github.com/nvim-lua/completion-nvim
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
Plugin 'itchyny/lightline.vim'

" Surrounding 
Plugin 'tpope/vim-surround'

" Highlight 
Plugin 'machakann/vim-highlightedyank'
let g:highlightedyank_highlight_duration = 500


call vundle#end()            " required


runtime macros/matchit.vim


filetype plugin indent on    " required

set laststatus=2
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab 

" hi clear Conceal

" colorscheme pablo
" highlight Normal      ctermbg=NONE guibg=NONE
" highlight NonText     ctermbg=NONE guibg=NONE
" highlight EndOfBuffer ctermbg=NONE guibg=NONE
" set cursorline
" highlight CursorLine cterm=underline gui=underline ctermbg=NONE guibg=NONE
" highlight CursorLineNr cterm=underline gui=underline ctermbg=NONE guibg=NONE

" ============================================================
" Colors
" ============================================================
set termguicolors
colorscheme pablo

" Preserve terminal background
highlight Normal       ctermbg=NONE guibg=NONE
highlight NonText      ctermbg=NONE guibg=NONE
highlight EndOfBuffer  ctermbg=NONE guibg=NONE
highlight LineNr       ctermbg=NONE guibg=NONE

" Underline the current row without a solid background
set cursorline
highlight CursorLine
      \ cterm=underline
      \ gui=underline
      \ ctermbg=NONE
      \ guibg=NONE

" Current line number: visible, but no colored block
highlight CursorLineNr
      \ cterm=bold,underline
      \ gui=bold,underline
      \ ctermfg=White
      \ guifg=#d7d7d7
      \ ctermbg=NONE
      \ guibg=NONE

" Make delimiters readable without recoloring all Special syntax
" highlight Delimiter
"       \ ctermfg=LightGrey
"       \ guifg=#bcbcbc
"
highlight Special ctermfg=117 guifg=#87d7ff
highlight VertSplit ctermfg=153 ctermbg=31 guifg=#afd7e7 guibg=#4f7187
highlight WinSeparator ctermfg=153 ctermbg=31 guifg=#afd7e7 guibg=#4f7187
autocmd User VimtexEventTocCreated highlight VimtexTocSec0 guifg=#87d7ff ctermfg=117 gui=bold cterm=bold
autocmd User VimtexEventTocCreated highlight VimtexTocSec1 guifg=#eeeeee ctermfg=255 gui=NONE cterm=NONE
autocmd User VimtexEventTocCreated highlight VimtexTocSec2 guifg=#c6c6c6 ctermfg=251 gui=NONE cterm=NONE
