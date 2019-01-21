" minwiki.vim - minimal wiki
" Maintainer: Ben Jones <https://www.github.com/davidbenjones>
" Version:    1.0

if !exists('g:minwiki_path')
	let g:minwiki_path = '~/wiki/'
endif

nnoremap <silent> <Plug>(minwiki-index) :call minwiki#Go('index.md')<CR>
nnoremap <silent> <Plug>(minwiki-go) :call minwiki#Go()<CR>
nnoremap <silent> <Plug>(minwiki-rename) :call minwiki#Rename()<CR>
nnoremap <silent> <Plug>(minwiki-delete) :call minwiki#Delete()<CR>

nnoremap <silent> <Plug>(minwiki-enter) :call minwiki#Enter()<CR>
nnoremap <silent> <Plug>(minwiki-prev-page) :call minwiki#PrevPage()<CR>
nnoremap <silent> <Plug>(minwiki-next-link) :<C-U>call minwiki#NextLink(v:count1)<CR>
nnoremap <silent> <Plug>(minwiki-prev-link) :<C-U>call minwiki#PrevLink(v:count1)<CR>

" set mapping to open wiki
nmap <Leader>ww <Plug>(minwiki-index)
nmap <Leader>wg <Plug>(minwiki-go)
nmap <Leader>wr <Plug>(minwiki-rename)
nmap <Leader>wd <Plug>(minwiki-delete)
