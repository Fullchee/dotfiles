" VIMRC (in progress)
" The comments may be a bit excessive because I'm still learning
" to turn an option off, have no, (eg noignorecase, nohls)


" Step 1: Install Pathogen: https://github.com/tpope/vim-pathogen
"execute pathogen#infect()
syntax on
filetype plugin indent on


" line numbers
set number 

" incremental search (is) (updates the search as you type)
" highlight search (hls)
set ignorecase incsearch hlsearch

" on by default, search the top after reaching the bottom
set wrapscan


" TABS AND SPACES
set tabstop=4       "pressing tab moves 4 visual spaces
set softtabstop=4   "using 
set expandtab       "tabs are spaces

set wildmenu        "when typing a command, press tab for visual autocomplete
set mouse=a         "almost like GUI
set pastetoggle=<F2> "in insert mode, press f2 to paste normally

"if there is a long wrapped line, it will go up one 'line' visually
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

# avoid the hotpinks in vimdiff to read the lines better
if &diff
    colorscheme evening
endif
