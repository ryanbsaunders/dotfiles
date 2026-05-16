" auto-install vim-plug on first run
let s:plug_bootstrap = 0
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let s:plug_bootstrap = 1
endif

" manage plugins with vim-plug
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'        " statusline
Plug 'vim-airline/vim-airline-themes' " airline themes
Plug 'rking/ag.vim'                   " ag / the-silver-searcher
Plug 'scrooloose/syntastic'           " syntastic syntax
Plug 'sjl/badwolf'                    " colorscheme
Plug 'tpope/vim-fugitive'             " git wrapper
Plug 'tpope/vim-rhubarb'              " gitHub plugin for vim-fugitive
Plug 'airblade/vim-gitgutter'         " git status
Plug 'rodjek/vim-puppet'              " puppet syntax support
Plug 'vim-ruby/vim-ruby'               " ruby syntax support
Plug 'scrooloose/nerdtree'            " nerdtree
Plug 'PProvost/vim-ps1'               " powershell syntax support
Plug 'pearofducks/ansible-vim'        " ansible syntax support
Plug 'vim-scripts/groovy.vim'         " groovy syntax support
Plug 'yorokobi/vim-splunk'            " splunk conf syntax support
Plug 'hashivim/vim-terraform'         " terraform support
Plug 'darfink/vim-plist'              " plist support
Plug 'godlygeek/tabular'               " text filtering and alignment
Plug 'vimwiki/vimwiki'                " vimwiki for wiki stuff with vim
Plug 'towolf/vim-helm'                " helm syntax
Plug 'dense-analysis/ale'             " asynchronous lint engine
Plug 'Yggdroot/indentLine'            " show indentation
Plug 'junegunn/fzf'                   " fzf
Plug 'junegunn/fzf.vim'               " fzf support
Plug 'mileszs/ack.vim'                " ack search support
Plug 'einenlum/yaml-revealer'         " yaml tree nav

call plug#end()

" on first run, install plugins then re-source vimrc so plugin-dependent
" config below (statusline, etc.) sees everything; finish here this pass
if s:plug_bootstrap
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  finish
endif

" Set the colorscheme if available
try
  colorscheme badwolf
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry

""" Basic configuration
set nocompatible                        " no vi compatibility
set mouse=                              " disable the damn mouse
set shell=/bin/bash                     " set the shell
set backspace=indent,eol,start          " allow all backspace use in insert
set number                              " show line numbers
set cursorline                          " highlight current line
set encoding=utf-8                      " set encoding
syntax on                               " turn on syntax highlighting
filetype plugin indent on               " turn on filetype detection plugin

" Set a leader
let mapleader=","

" set pastetoggle
set pastetoggle=<F9>

" configure clipboard
set clipboard=unnamed

" mappings
inoremap jk <ESC>
noremap op O<ESC>o
noremap tt <F9>i

" highlight unwanted characters
set list
set listchars=tab:»·,trail:·

" jump to last position when re-opening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif
" except for git commits
autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0])

" airline configuration
set laststatus=2    " always enable status bar

let g:airline_powerline_fonts = 1   " user powerline fonts

" enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

""" buffer configuration
" allow a buffer to be hidden if modified
set hidden

""" syntastic configuration
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_puppet_puppetlint_args='--no-80chars-check --no-class_inherits_from_params_class-check --no-variable_scope-check --no-documentation-check --no-autoloader_layout-check'
let g:syntastic_javascript_checkers = ['syntastic-javascript-jshint']

let g:ansible_unindent_after_newline = 1
let g:terraform_fmt_on_save=1

""" shortcuts
" move between open buffers
nmap <C-n> :bnext<CR>
nmap <C-p> :bprev<CR>
nnoremap <Leader>ne :NERDTree<CR>

" 2 space tabs for yaml files
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
set expandtab
set shiftwidth=2
set tabstop=2

" make navigation easier
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" make splitting panes not stupid
set splitbelow
set splitright

" ultisnips setup
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" set up ALE
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
let g:ale_lint_on_text_changed = 'never'

" set up ack.vim
let g:ackprg = 'ag --nogroup --nocolor --column'
