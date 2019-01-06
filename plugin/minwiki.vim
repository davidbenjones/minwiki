if !exists('g:minwiki_path')
	let g:minwiki_path = '~/wiki/'
endif

function s:setbindings()
	nnoremap <buffer> <CR> :call minwiki#Enter()<CR>
	nnoremap <buffer> <BS> :call minwiki#PrevPage()<CR>
	nnoremap <buffer> <Tab> :call minwiki#NextLink()<CR>
	nnoremap <buffer> <S-Tab> :call minwiki#PrevLink()<CR>
endfunction

" set mapping to open wiki
nnoremap <Leader>ww :call minwiki#Go('index')<CR>

" set leaders for special files
augroup minwiki
	autocmd!
	exec "autocmd BufRead,BufNewFile" g:minwiki_path . "*" "call s:setbindings()"
	exec "autocmd WinNew" g:minwiki_path . "*" "let w:minwiki_history = []"
augroup END
