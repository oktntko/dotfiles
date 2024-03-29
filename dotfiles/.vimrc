"        ________ ++     ________
"       /VVVVVVVV\++++  /VVVVVVVV\
"       \VVVVVVVV/++++++\VVVVVVVV/
"        |VVVVVV|++++++++/VVVVV/'
"        |VVVVVV|++++++/VVVVV/'
"       +|VVVVVV|++++/VVVVV/'+
"     +++|VVVVVV|++/VVVVV/'+++++
"   +++++|VVVVVV|/VVV___++++++++++
"     +++|VVVVVVVVVV/##/ +_+_+_+_
"       +|VVVVVVVVV___ +/#_#,#_#,\
"        |VVVVVVV//##/+/#/+/#/'/#/
"        |VVVVV/'+/#/+/#/+/#/ /#/
"        |VVV/'++/#/+/#/ /#/ /#/
"        'V/'  /##//##//##//###/
"                 ++

" Automatic installation on startup
let s:jetpackfile = "$HOME/.vim/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim"
let s:jetpackurl = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"
if !filereadable(s:jetpackfile)
  call system(printf('curl --fail --silent --show-error --location --output %s --create-dirs %s', s:jetpackfile, s:jetpackurl))
endif

" Plugins
packadd vim-jetpack
call jetpack#begin()
Jetpack 'tani/vim-jetpack', {'opt': 1} " bootstrap
Jetpack 'tomasr/molokai'     " カラーテーマ
Jetpack 'preservim/nerdtree' |
  \ Jetpack 'Xuyuanp/nerdtree-git-plugin' |
  \ Jetpack 'ryanoasis/vim-devicons'        " エクスプローラー表示とgitプラグインとアイコン
Jetpack 'airblade/vim-gitgutter'
call jetpack#end()

syntax on
colorscheme molokai
set t_Co=256
filetype plugin indent on
set encoding=utf-8

" 画面表示の設定
set number         " 行番号を表示する
set cursorline     " カーソル行の背景色を変える
set laststatus=2   " ステータス行を常に表示
set cmdheight=1    " メッセージ表示欄を行確保
set showmatch      " 対応する括弧を強調表示
set matchtime=1    "
set helpheight=999 " ヘルプを画面いっぱいに開く
set list           " 不可視文字を表示
" 不可視文字の表示記号指定
" tab: “タブ”の表示を決定する。
" trail: 行末に続くスペースを表す表示。
" eol: 改行記号を表す表示。
" extends: ウィンドウの幅が狭くて右に省略された文字がある場合に表示される。
" precedes: extends と同じで左に省略された文字がある場合に表示される。
" nbsp: 不可視のスペースを表す表示。
set listchars=tab:»-,trail:-,extends:»,precedes:«

" カーソル移動関連の設定
set backspace=indent,eol,start " Backspaceキーの影響範囲に制限を設けない
set whichwrap=b,s,h,l,<,>,[,]  " 行頭行末の左右移動で行をまたぐ
set scrolloff=8                " 上下8行の視界を確保
set sidescrolloff=16           " 左右スクロール時の視界を確保
set sidescroll=1               " 左右スクロールは一文字づつ行う

" ファイル処理関連の設定
set confirm    " 保存されていないファイルがあるときは終了前に保存確認
set hidden     " 保存されていないファイルがあるときでも別のファイルを開くことが出来る
set autoread   " 外部でファイルに変更がされた場合は読みなおす
set nobackup   " ファイル保存時にバックアップファイルを作らない
set noswapfile " ファイル編集中にスワップファイルを作らない

" 検索/置換の設定
set hlsearch   " 検索文字列をハイライトする
set incsearch  " インクリメンタルサーチを行う
set ignorecase " 大文字と小文字を区別しない
set smartcase  " 大文字と小文字が混在した言葉で検索を行った場合に限り、大文字と小文字を区別する
set wrapscan   " 最後尾まで検索を終えたら次の検索で先頭に移る
set gdefault   " 置換の時 g オプションをデフォルトで有効にする

" タブ/インデントの設定
set expandtab     " タブ入力を複数の空白入力に置き換える
set tabstop=2     " 画面上でタブ文字が占める幅
set shiftwidth=2  " 自動インデントでずれる幅
set softtabstop=2 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent    " 改行時に前の行のインデントを継続する
set smartindent   " 改行時に入力された行の末尾に合わせて次の行のインデントを増減する

" ビープの設定
"ビープ音すべてを無効にする
set visualbell t_vb=
set noerrorbells "エラーメッセージの表示時にビープを鳴らさない

" ショートカット
map <C-i> :JetpackSync<CR>    # vim-jetpack install
map <C-n> :NERDTreeToggle<CR> # nerdtree で開く
map <C-s> :w<CR>              # 保存
map <C-w> :q!<CR>             # 保存せず終了

" Automatic plugin installation on startup
for name in jetpack#names()
  if !jetpack#tap(name)
    call jetpack#sync()
    break
  endif
endfor
