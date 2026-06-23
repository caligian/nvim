function! HideWindowIfPossible()
  if winnr('$') > 1
    hide
  else
    bprev
  endif
endfunction

function! DeleteBufferWindowIfPossible()
  if winnr('$') > 1
    bdelete % 
    hide
  else
    bdelete %
  endif
endfunction

function! WipeoutBufferWindowIfPossible()
  if winnr('$') > 1
    bwipeout %
    hide
  else
    bwipeout %
  endif
endfunction

set mouse=a
set autochdir
set sw=4
set tabstop=4
set sts=4
set expandtab
set autoindent
set number
set relativenumber
set autochdir
set relativenumber

let mapleader = " "
let maplocalleader = "<C-x>"

au FileType lua,nix,sh,bash set sw=2 tabstop=2 sts=2 expandtab
au FileType help noremap <buffer> q :call HideWindowIfPossible() <CR>
au FileType help noremap <buffer> Q :call DeleteBufferWindowIfPossible() <CR>

aunmenu PopUp

nnoremap <C-Up> :resize +5 <CR>
nnoremap <C-Down> :resize -5 <CR>
nnoremap <C-Left> :vertical resize -5 <CR>
nnoremap <C-Right> :vertical resize +5 <CR>

nnoremap <leader>bk :call HideWindowIfPossible() <CR>
nnoremap <leader>bQ :bwipeout %<CR>
nnoremap <leader>bq :call WipeoutBufferWindowIfPossible() <CR>
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprev<CR>

nnoremap <leader>fs :w<CR>
nnoremap <leader>fv :w <bar> luafile % <CR>
nnoremap <leader>fV :w <bar> source % <CR>
nnoremap <leader>f. :e .<CR>

nnoremap <C-g> :noh <CR>
nnoremap <C-x>. :!ls -lctrshA <CR>
nnoremap <M-.> : 
nnoremap <M-!> :! 

nnoremap <RightMouse> <Nop>
inoremap <RightMouse> <Nop>
vnoremap <RightMouse> <Nop>

autocmd TextYankPost * silent! lua vim.hl.on_yank {higroup='Visual', timeout=300}
