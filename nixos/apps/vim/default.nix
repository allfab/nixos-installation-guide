with import <nixpkgs> {};

vim_configurable.customize {
    # Specifies the vim binary name.
    # E.g. set this to "my-vim" and you need to type "my-vim" to open this vim
    # This allows to have multiple vim packages installed (e.g. with a different set of plugins)
    name = "vim";
    vimrcConfig.customRC = ''
        " ~/.vimrc
        syntax on
        colorscheme desert
        set textwidth=79
        set scrolloff=15
        set autoindent
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set modeline modelines=2
    '';
}