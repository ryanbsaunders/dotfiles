" Manage plugins with Vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'    "Manage Vundle with Vundle

" Plugins to install with Vundle
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/syntastic'
Plugin 'sjl/badwolf'              " Colorscheme
Plugin 'tpope/vim-fugitive'       " Git wrapper
Plugin 'tpope/vim-rhubarb'        " GitHub plugin for vim-fugitive
Plugin 'airblade/vim-gitgutter'
Plugin 'rodjek/vim-puppet'        " Puppet syntax support
Plugin 'vim-ruby/vim-ruby'        " Ruby syntax support
Plugin 'scrooloose/nerdtree'
Plugin 'PProvost/vim-ps1'         " Powershell syntax support
Plugin 'pearofducks/ansible-vim'  " Ansible syntax support
Plugin 'vim-scripts/groovy.vim'   " Groovy syntax support
call vundle#end()

" Basic configuration
colorscheme badwolf
set nocompatible    " No vi compatibility
set mouse=    " Disable the damn mouse
set shell=/bin/bash
set backspace=indent,eol,start
set number    " show line numbers
set cursorline " highlight current line
syntax on   " Turn on syntax highlighting
filetype plugin indent on   " Turn on filetype detection plugin

" Set a leader
:let mapleader=","

" Mappings
inoremap jk <ESC>

" Highlight unwanted characters
set list
set listchars=tab:»·,trail:·

" Jump to last position when re-opening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif
" except for git commits
autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0])

" Airline Configuration
set laststatus=2    " Always enable status bar

let g:airline_section_gutter = '%= %{strftime("%R")}'   " Add time
let g:airline_powerline_fonts = 1   " User powerline fonts

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

""" Buffer configuration
" Allow a buffer to be hidden if modified
set hidden

""" Syntastic Configuration
" Syntastic recommended settings for newbs
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_puppet_puppetlint_args='--no-80chars-check --no-class_inherits_from_params_class-check --no-variable_scope-check --no-documentation-check --no-autoloader_layout-check'

""" Shortcuts
" Move between open buffers.
nmap <C-n> :bnext<CR>
nmap <C-p> :bprev<CR>
nnoremap <Leader>ne :NERDTree<CR>

" 2 space tabs for YAML files
"autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
set expandtab
set shiftwidth=2
set tabstop=2
