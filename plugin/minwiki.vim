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
	exec "autocmd TabNew" g:minwiki_path . "*" "let t:minwiki_history = []"
augroup END

	" TODO: write file on close buffer
	" TODO: automatically create a link

	" consider using autoload for some of this, with the remaps
	" inside of a dedicated file
	" TODO: delete wiki page
	" TODO: rename wiki page (and update existing links!)
	" TODO: highlight links
	" TODO: option: use normal markdown links
