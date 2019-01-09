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
nnoremap <Leader>ww :call minwiki#Go('index.md')<CR>

" set leaders for special files
augroup minwiki
	autocmd!
	exec "autocmd BufRead,BufNewFile" g:minwiki_path . "*" "call s:setbindings()"
	exec "autocmd WinNew" g:minwiki_path . "*" "let w:minwiki_history = []"
augroup END

" NOTE: When a window is split, the new window does *not* have the same
" window-scoped variables (in particular, the history is lost); however,
" WinNew is called, so `w:minwiki_history = []`, which seems like acceptable
" behavior. It's technically a new window, so it shouldn't have the same
" history as the previous window. Furthermore, I don't see any obvious way
" of copying the history from one window to another without dabbling in some
" kind of messy buffer-scoped variables.

" THOUGHT: Have links be the best of both worlds: When reading a file, convert
" any markdown links referencing wiki pages to [[ link ]]-style links. Then,
" when the user saves again, convert the links back to normal markdown-style
" links. The conversion shouldn't mess with any characters outside of the
" links. It might work to "conceal" text instead, but I don't know enough
" about that, and I want the text to be more or less editable as is.
"
" This would be relatively straightforward with :%s/pattern/replace/g
" if using submatch() and submatch expressions.
"
" I'm debating whether or not [[ link ]]-style links should allow the ability
" to reference alternate text, which Wikipedia does via
" [[article name|shown text]], at which point it would make the most sense to
" just force all links to be markdown links.
"
" Markdown images look like this: ![](./asdf.jpg)

function! Trep()
	%s/<b\(uffer\)>/\="(s" . submatch(1) . ")"/ge
	" see :help flags
endfunction
