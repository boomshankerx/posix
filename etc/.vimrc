" 
" pathogen
"runtime bundle/vim-pathogen/autoload/pathogen.vim
"call pathogen#infect()

"set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')
" PLUGINS
Plug 'SirVer/ultisnips'
Plug 'airblade/vim-gitgutter'
Plug 'alvan/vim-closetag'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'docunext/closetag.vim'
Plug 'easymotion/vim-easymotion'
Plug 'elzr/vim-json' 
Plug 'ervandew/supertab'
Plug 'godlygeek/tabular'
Plug 'honza/vim-snippets'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/vim-easy-align'
Plug 'justinmk/vim-sneak'
Plug 'mattn/emmet-vim'
Plug 'pangloss/vim-javascript'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'sjl/gundo.vim'
Plug 'tomtom/tlib_vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-cucumber'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-pathogen'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired' 
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/Align'
Plug 'vim-scripts/utl.vim'
Plug 'vim-syntastic/syntastic'

" PLUGINS OPTIONAL
"Plug 'Valloric/YouCompleteMe'
"Plug 'junegunn/fzf'
"Plug 'majutsushi/tagbar'

" COLOR SCHEMES
Plug 'cocopon/iceberg.vim'
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'nordtheme/vim'
Plug 'tomasr/molokai'

call plug#end()

" GENERAL
filetype plugin indent on
set backspace=start,indent,eol
set clipboard=unnamedplus
set cursorline
set diffopt+=vertical
set encoding=utf-8
set history=50
set hlsearch
set incsearch
set laststatus=2
set nocompatible
set nowrap
set number relativenumber
set ruler
set showcmd
set showmatch
set splitbelow
set splitright
set textwidth=0

" VISUAL
"set columns=110
"set lines=40
"set t_Co=256
colorscheme onedark
set background=dark
set guifont=FiraCode\ Nerd\ Font\ Mono\ 14
syntax enable
if (has("termguicolors"))
    set termguicolors
endif

" INDENTING
set autoindent
set expandtab
set shiftwidth=4
set smartindent
set softtabstop=4
set tabstop=4
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" FOLDING
set foldmethod=indent
set foldlevel=99

" AUTO COMPLETION
set omnifunc=syntaxcomplete#Complete
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd FileType c set omnifunc=ccomplete#Complete
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType python set omnifunc=python3complete#Complete
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags

" PLUGIN SETTINGS
let g:NERDTreeShowHidden               = 1
let g:airline_powerline_fonts          = 1
let g:airline_theme                    = 'powerlineish'
let g:closetag_filenames               = '*.html,*.ovpn,*.xhtml,*.phtml'
let g:django_filetypes                 = '*.py'
let g:jedi#auto_close_doc              = 1
let g:jedi#completions_command         = "<C-Space>"
let g:proj_run1                        = ':vnew %f'
let g:syntastic_python_checkers        = ['python3']
let g:user_emmet_leader_key            = ','

" SUPERTAB/ULTISNIPS/YCM
let g:SuperTabDefaultCompletionType    = "<C-n>"
let g:UltiSnipsExpandTrigger           = "<tab>"
let g:UltiSnipsJumpForwardTrigger      = "<tab>"
let g:UltiSnipsJumpBackwardTrigger     = "<s-tab>"
let g:UltiSnipsListSnippets            = "<C-S-k>" "List possible snippets based on current file
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:ycm_key_list_select_completion   = ['<C-n>', '<Down>']

" HTML
autocmd Filetype html,ovpn,xhtml,xml,xsl source ~/.vim/bundle/closetag.vim/plugin/closetag.vim
autocmd Filetype html,xhtml,php set nowrap

"
" KEYBOARD MAPS
"

" Comments
nnoremap <C-/> <plug>NERDCommenterToggle
nnoremap <C-_> <plug>NERDCommenterToggle
nmap qq gcc
vnoremap <C-/> <plug>NERDCommenterToggle<CR>gv
vnoremap <C-_> <plug>NERDCommenterToggle<CR>gv
vmap q gc

" NORMAL MODE
nnoremap <C-Enter> <ESC>"+gPa
nnoremap <C-c> V"+y
nnoremap <Enter> <C-w>W
nnoremap <F3> :CtrlP<CR>
nnoremap <F4> :NERDTree<CR>
nnoremap <F5> :w<CR>
nnoremap <S-Space> <C-w>W
nnoremap <Space> <C-w>w
nnoremap <leader>v :so ~/.vimrc<CR>
nnoremap <leader>vv :e ~/.vimrc<CR>
nnoremap <silent> <C-s> :update<CR>
nnoremap VC ggVGy
nnoremap VV ggVG

" SWAP LINE UP AND DOWN
if has('gui_running') 
    nnoremap <M-j> :m .+1<CR>==
    nnoremap <M-k> :m .-2<CR>==
else
    nnoremap j :m .+1<CR>==
    nnoremap k :m .-2<CR>==
endif

" INSERT MODE
inoremap <C-Enter> <ESC>"+gPa
inoremap <C-v> <C-r><C-o>+
inoremap JJ <ESC>
inoremap jj <ESC>

" VISUAL MODE
vnoremap <C-c> "+yi
vnoremap <F4> :sort<CR>
vnoremap <F9> :sort<CR>
