# minwiki

I tried out [vimwiki](https://github.com/vimwiki/vimwiki) and loved its
features, but I didn't like the way it mangled my markdown, particularly the
syntax highlighting, so I created this minimal version with only the features
that I use: creating links, following links, minor navigation.

There will probably be support for a few more features when I get the chance,
but this is all I have time for. Most of the keybindings are the same as
vimwiki.

## Installing

Use [vim-plug](https://github.com/junegunn/vim-plug) to install the plugin. If
you use other plugin managers, you're on your own for now.

### vim-plug

Add this to your `vimrc` between `plug#begin` and `plug#end`:

```vim
Plug 'davidbenjones/minwiki'
```

## License

This project is licensed under [GPL v3.0](LICENSE).
