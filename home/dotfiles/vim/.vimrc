set nocompatible

colorscheme darkblue
syntax on
set nobackup
set tabstop=4
set shiftwidth=4
set softtabstop=0
set expandtab
set smartindent
set shiftround
set nolist
set formatoptions-=r
set showcmd
set hidden
set history=50
set backspace=indent,eol,start
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan
set ruler
set laststatus=2
set nu
set wildmenu
set formatoptions=M
set confirm
set listchars=tab:>.,extends:~,trail:_,eol:<
set viminfo=%,'50,\"100,:100,n~/.vim/.viminfo
set suffixes=.bak,~,.swp,.o,.info,.aux,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc


set mouse=a
if &term == "screen"
  set ttymouse=xterm
endif
set nocompatible

highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=white
match ZenkakuSpace /¡¡/

nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz

" display¡¡
"-----------------------------------------------------------
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  colorscheme darkblue
  set hlsearch
endif

set shortmess+=I

set list
set listchars=tab:>-,trail:-,extends:>,precedes:<
set display=uhex

set laststatus=2
set cmdheight=2
set showcmd
set title

set scrolloff=2

"set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
set statusline=%<%f\ %m%r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%4v\ %l/%L

" search
"-----------------------------------------------------------
set incsearch
set ignorecase
set smartcase

" edit
"-----------------------------------------------------------
set autoindent
set backspace=indent,eol,start
set showmatch
set wildmenu
set formatoptions+=mM

" tab
"-----------------------------------------------------------
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab
inoremap <C-Tab> <C-V><Tab>

" backup
"-----------------------------------------------------------
" set backup
" set backupdir=~/.vim/vim_backup
" set swapfile
" set directory=~/.vim/vim_swap

" key map
" move at line
nnoremap j gj
nnoremap k gk

" input time
inoremap <Leader>date <C-R>=strftime('%A, %B %d, %Y')<CR>
inoremap <Leader>time <C-R>=strftime('%H:%M')<CR>
inoremap <Leader>rdate <C-R>=strftime('%A, %B %d, %Y %H:%M')<CR>
inoremap <Leader>w3cdtf <C-R>=strftime('%Y-%m-%dT%H:%M:%S+09:00')<CR>

" search
vnoremap * "zy:let @/ = @z<CR>n

" putline
"-----------------------------------------------------------
let putline_tw = 60

inoremap <Leader>line <ESC>:call <SID>PutLine(putline_tw)<CR>A
function! s:PutLine(len)
  let plen = a:len - strlen(getline('.'))
  if (plen > 0)
    execute 'normal ' plen . 'A-'
  endif
endfunction

" utf-8
"-----------------------------------------------------------
"let &termencoding=&encoding
"set termencoding=utf-8
set encoding=utf-8
"set encoding=euc-jp
set fileencodings=utf-8,euc-jp,ucs-bom,iso-2022-jp-3,iso-2022-jp-2,euc-jisx0213,cp932
set fileformats=unix,dos,mac

if &encoding == 'utf-8'
  set ambiwidth=double
endif

" format.vim
"-----------------------------------------------------------
let format_allow_over_tw = 0

" chalice
"-----------------------------------------------------------
set runtimepath+=$HOME/.vim/chalice
nnoremap <F2> :call <SID>DoChalice()<CR>
let chalice_preview = 0
let chalice_columns = 120
let chalice_exbrowser = 'openurl %URL% &'
function! s:DoChalice()
  Chalice
endfunction

" autodate
"-----------------------------------------------------------
let g:autodate_format = '%Y-%m-%d'
let g:autodate_keyword_pre = 'Last Modified:'
let g:autodate_keyword_post = '$'

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

endif " has("autocmd")

nnoremap <silent> ,ha :HighlightCurrentLine Search<cr>
nnoremap <silent> ,hb :HighlightCurrentLine DiffAdd<cr>
nnoremap <silent> ,hc :HighlightCurrentLine Error<cr>
command! -nargs=1 HighlightCurrentLine execute 'match <args> /<bslash>%'.line('.').'l/'

nnoremap <silent> ,H :UnHighlightCurrentLine<cr>
command! -nargs=0 UnHighlightCurrentLine match

