" NOTE: This differs from the normal plugin style because it has to be loaded
" alongside the markdown filetype plugin. Using b:did_ftplugin would cause
" only the first listed filetype to be loaded.

if exists("b:did_minwiki_ftplugin")
	finish
endif
let b:did_minwiki_ftplugin = 1

nmap <silent> <buffer> <CR> <Plug>(minwiki-enter)
nmap <silent> <buffer> <BS> <Plug>(minwiki-prev-page)
nmap <silent> <buffer> <Tab> <Plug>(minwiki-next-link)
nmap <silent> <buffer> <S-Tab> <Plug>(minwiki-prev-link)

if !exists("w:minwiki_history")
	let w:minwiki_history = []
endif
