set nocompatible

"gestionnaire de paquets
execute pathogen#infect()

set background=light
colorscheme onehalflight

let mapleader=","

syntax on
filetype plugin indent on
set tabstop=2 "les tabulations ont une taille de deux espaces
set shiftwidth=2 "utilise une taille de 2 espaces pour l'indentation automatique
set number "affiche les numéros de lignes
set mouse=a "active la souris en mode console
set autoindent
set ts=2
set autochdir "le dossier courant est celui du fichier ouvert
set bs=indent,eol,start
set guioptions-=T "supprime la barre d'icone dans gvim
set guioptions-=m "supprime la barre de menu dans gvim
set hidden "permet de changer de buffer même si le buffer courant est modifié
set visualbell t_vb= "désactive les beep désagréables
set ignorecase

"la liste des modifications est sauvegardé et est accessible même après avoir
"quitté vim.
if !isdirectory($HOME."/.vim/undodir")
	call mkdir($HOME."/.vim/undodir", "p")
endif
set undodir=~/.vim/undodir
set undofile
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on a buffer reload

"place tous les fichiers swp dans un unique dossier
if !isdirectory($HOME."/.vim/swp")
	call mkdir($HOME."/.vim/swp", "p")
endif
set directory=~/.vim/swp//

"surbrillance des caractères invisibles
"set listchars+=eol:¬
"set listchars+=tab:>―
"set listchars+=trail:~
"set listchars+=space:·
"set list

set clipboard=unnamedplus "activation du copier coller de Xorg
set cursorline "mise en surbrillance de la ligne actuelle
set incsearch
set laststatus=2 "toujours afficher la barre de status

"place le curseur à la position qu'il avait lors de la précédente ouverture du fichier (viminfo)
if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"configuration du menu d'auto-complétition des commandes
set wildmenu "activation du menu d'auto-complétition dans la barre de commande
set wildignorecase "insenible à la casse
"un appui sur tab complète le plus possible et affiche le wildmenu,
"un second appui auto-complète avec la première correspondance et les autres
"appuis parcourent sur les suivantes
set wildmode=longest:full,full
"ignore ces fichiers lors de l'aucomplétition avec tab, ou encore lors d'une
"recherche avec le plugin ctrl-p
set wildignore+=*.o,*.mod,*.h5,*.fdeps

"la vue du fichier reste la même lorsque l'on change puis reviens sur un buffer
au BufLeave * let b:winview = winsaveview()
au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif

"Latex option
autocmd FileType tex setlocal shiftwidth=2 tabstop=2

"remplace la commande bd par celle de vim-bufkill
cabbrev bd <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'BD' : 'bdelete')<CR>

"échappe instantané
set timeoutlen=1000 ttimeoutlen=0

"déplace le curseur d'une ligne visuel
nnoremap j gj
nnoremap k gk

"ras le bol de tapper W à la place de w
command W w
command Wq wq

"rend possible de naviguer avec % à travers les if/else/do
packadd! matchit

"netrw configuration
let g:netrw_banner = 0 "remove the banner
let g:netrw_liststyle = 3 "tree style listing
let g:netrw_browse_split = 4 "when selected, open file in previously used window
let g:netrw_winsize = 25

"==========================
" Configuration des plugins
"==========================

"affiche une liste des buffers en haut de la fenêtre (plugin airline)
let g:airline#extensions#tabline#enabled = 1
let g:vaxe_enable_airline_defaults = 0
let g:airline_theme='onehalflight'

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'start'
