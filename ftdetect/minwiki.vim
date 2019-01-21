" needs to check every file because we need value of
" g:minwiki_path when the file is open, not right now
autocmd BufRead,BufNewFile *
	\ if expand('%:p:h') ==? fnamemodify(g:minwiki_path, ':p:h') |
	\ set filetype=markdown.minwiki |
	\ endif
