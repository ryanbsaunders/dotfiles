" manage plugins with vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'           "manage vundle with vundle

" plugins to install with vundle
Plugin 'vim-airline/vim-airline'        " statusline
Plugin 'vim-airline/vim-airline-themes' " airline themes
Plugin 'rking/ag.vim'                   " ag / the-silver-searcher
Plugin 'scrooloose/syntastic'           " syntastic syntax
Plugin 'sjl/badwolf'                    " colorscheme
Plugin 'tpope/vim-fugitive'             " git wrapper
Plugin 'tpope/vim-rhubarb'              " gitHub plugin for vim-fugitive
Plugin 'airblade/vim-gitgutter'         " git status
Plugin 'rodjek/vim-puppet'              " puppet syntax support
Plugin 'vim-ruby/vim-ruby'              " ruby syntax support
Plugin 'scrooloose/nerdtree'            " nerdtree
Plugin 'PProvost/vim-ps1'               " powershell syntax support
Plugin 'pearofducks/ansible-vim'        " ansible syntax support
Plugin 'vim-scripts/groovy.vim'         " groovy syntax support
Plugin 'yorokobi/vim-splunk'            " splunk conf syntax support
Plugin 'hashivim/vim-terraform'         " terraform support
Plugin 'darfink/vim-plist'              " plist support
Plugin 'godlygeek/tabular'              " text filtering and alignment
Plugin 'vimwiki/vimwiki'                " vimwiki for wiki stuff with vim
Plugin 'towolf/vim-helm'                " helm syntax
Plugin 'dense-analysis/ale'             " asynchronous lint engine
Plugin 'Yggdroot/indentLine'            " show indentation
Plugin 'junegunn/fzf'                   " fzf
Plugin 'junegunn/fzf.vim'               " fzf support
Plugin 'mileszs/ack.vim'                " ack search support

call vundle#end()

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
