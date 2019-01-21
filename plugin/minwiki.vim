" minwiki.vim - minimal wiki
" Maintainer: Ben Jones <https://www.github.com/davidbenjones>
" Version:    1.0

if !exists('g:minwiki_path')
	let g:minwiki_path = '~/wiki/'
endif

function s:setbindings()
	nnoremap <silent> <buffer> <CR> :call minwiki#Enter()<CR>
	nnoremap <silent> <buffer> <BS> :call minwiki#PrevPage()<CR>
	nnoremap <silent> <buffer> <Tab> :<C-U>call minwiki#NextLink(v:count1)<CR>
	nnoremap <silent> <buffer> <S-Tab> :<C-U>call minwiki#PrevLink(v:count1)<CR>
endfunction

" set mapping to open wiki
nnoremap <Leader>ww :call minwiki#Go('index.md')<CR>
nnoremap <Leader>wg :call minwiki#Go()<CR>
nnoremap <Leader>wr :call minwiki#Rename()<CR>
nnoremap <Leader>wd :call minwiki#Delete()<CR>

" set leaders for special files
augroup minwiki
	autocmd!
	exec "autocmd BufRead,BufNewFile" g:minwiki_path . "*" "call s:setbindings()"
	exec "autocmd WinNew" g:minwiki_path . "*" "let w:minwiki_history = []"
augroup END
