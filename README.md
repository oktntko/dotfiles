# dotfiles

## Install
```
curl -fsSL https://raw.githubusercontent.com/oktntko/dotfiles/main/install.zsh | zsh
```

### Requirements

See `.docker/path/to/Dockerfile`.  
For example on Ubuntu, see [Ubuntu](.docker/debian/ubuntu/Dockerfile) `# How to setup`.  

## Tools

- Shell: **zsh**
  - Plugin Manager
    - [Zim](https://zimfw.sh/)
  - Plugins
    - [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
    - zsh-users/zsh-completions
    - zsh-users/zsh-syntax-highlighting
    - zsh-users/zsh-autosuggestions
    - Aloxaf/fzf-tab
    - b4b4r07/enhancd
- Package Manager
  - [yay](https://github.com/Jguer/yay)
    - On Arch Linux. [AUR ヘルパー](https://wiki.archlinux.jp/index.php/AUR_%E3%83%98%E3%83%AB%E3%83%91%E3%83%BC)
  - [Homebrew](https://brew.sh/)
    - On Non-Arch Linux
- Command Line Tools
  - [bat](https://github.com/sharkdp/bat)
    - A cat(1) clone with syntax highlighting and Git integration.
  - [ripgrep](https://github.com/BurntSushi/ripgrep)
    - ripgrep is a line-oriented search tool that recursively searches the current directory for a regex pattern.
  - [fzf](https://github.com/junegunn/fzf)
    - fzf is a general-purpose command-line fuzzy finder.
    - Key bindings
      - `Ctrl + R` : xxx
      - `Ctrl + T` : xxx
      - `Alt  + C` : xxx
  - [exa](https://the.exa.website/)
    - A modern replacement for ls.
  - [delta](https://dandavison.github.io/delta/)
    - A syntax-highlighting pager for git, diff, and grep output
- Runtime Version Management Tool: **[asdf](https://asdf-vm.com/)**
  - Default plugin
    - [Java](https://github.com/halcyon/asdf-java)
    - [Python](https://github.com/asdf-community/asdf-python)
    - [Nodejs](https://github.com/asdf-vm/asdf-nodejs)
- Editor: **[vim](https://github.com/vim/vim)**
  - Plugin Manager
    - [Jetpack.vim](https://gist.asciidoctor.org/?github-tani/vim-jetpack/main//README.adoc&source-highlighter=highlightjs)
  - Plugins
    - tomasr/molokai
    - preservim/nerdtree
    - Xuyuanp/nerdtree-git-plugin
    - ryanoasis/vim-devicons
    - airblade/vim-gitgutter
