set nocompatible

"gestionnaire de paquets
execute pathogen#infect()

colorscheme jellybeans

let mapleader=","

syntax on
filetype plugin on
set number "affiche les numéros de lignes
set mouse=a "active la souris en mode console
set autoindent
set ts=2
set autochdir "le dossier courant est celui du fichier ouvert
set bs=indent,eol,start
set guioptions-=T "supprime la barre d'icone dans gvim
set guioptions-=m "supprime la barre de menu dans gvim
set hidden "permet de changer de buffer même si le buffer courant est modifié

"persistent undo
if !isdirectory($HOME."/.vim/undodir")
	call mkdir($HOME."/.vim/undodir", "p")
endif
set undodir=~/.vim/undodir
set undofile
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on a buffer reload

"surbrillance des caractères invisibles
set listchars+=eol:¬
set listchars+=tab:..
set listchars+=trail:~
"set listchars+=space:·
set list

set clipboard=unnamedplus "activation du copier coller de Xorg
set cursorline "mise en surbrillance de la ligne actuelle
set wildmenu "menu pour auto-complétition dans la barre de commande
set incsearch
set laststatus=2 "toujours afficher la barre de status

"place le curseur à la position qu'il avait lors de la précédente ouverture du fichier (viminfo)
if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"affiche une liste des buffers en haut de la fenêtre (plugin airline)
let g:airline#extensions#tabline#enabled = 1

"ignore ces fichiers lors de l'aucomplétition avec tab, ou encore lors d'une
"recherche avec ctrl-p
set wildignore+=*.o,*.mod,*.h5,*.fdeps

"spécifique au plugin vim-go
let g:go_fmt_command = "goimports"
autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>r  <Plug>(go-run)

"raccourçis pour naviguer dans les buffers comme sur un navigateur web et ses onglets
"fonctionne sous gvim et quelque terminaux, voir:
"https://superuser.com/questions/787280/ctrltab-is-not-working-in-vim-with-gnome-terminal
"
"controle + tab pour le buffer suivant (en mode normal)
nnoremap <C-tab> :bn<CR>
"controle + tab pour le buffer suivant (en mode insertion)
inoremap <C-tab> <Esc>:bn<CR>
"controle + shift + tab pour le buffer précédent (en mode normal)
nnoremap <C-S-tab> :bp<CR>
"controle + shift + tab pour le buffer précédent (en mode insertion)
inoremap <C-S-tab> <Esc>:bp<CR>
"controle + w pour fermer le buffer (en mode normal)
nnoremap <C-W> :bd<CR><Esc>
"controle + w pour fermer le buffer (en mode insertion)
inoremap <C-W> <Esc>:bd<CR><Esc>

"la vue du fichier reste la même lorsque l'on change puis reviens sur un buffer
au BufLeave * let b:winview = winsaveview()
au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
