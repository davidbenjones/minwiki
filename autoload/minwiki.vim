function minwiki#Go(page_name) 
	let page_path = g:minwiki_path . a:page_name . ".md"
	if s:iswiki()
		write
		let current_buffer = bufnr('%')
		exe "edit " . page_path
		exe "bwipeout " . current_buffer
	else
		exe "tab drop " . page_path
		let t:minwiki_history = []
	endif
	call add(t:minwiki_history, a:page_name)
endfunction

" plan:
" 	search forward for position of ]]
" 	search backward from ]] for position of [[
" 	if cursor is inside, get characters

function s:getlink()
	let current_character = matchstr(getline('.'), '\%'.col('.').'c.')
	if current_character == '['
		normal! l
	endif

	let end_pos = searchpairpos('\[\[','','\]\]','ncW')
	let end_column = end_pos[1]
	let end_line = end_pos[0]

	let start_pos = searchpairpos('\[\[','','\]\]','ncbW')
	let start_column = start_pos[1]
	let start_line = start_pos[0]

	if current_character == '['
		normal! h
	endif

	" if the braces don't match, return an empty string
	if start_line == 0 || start_column == 0
		return ""
	endif

	let lines = getline(start_line,end_line)

	" trim excess at start and end
	let lines[0] = lines[0][start_column+1:]
	let lines[-1] = substitute(lines[-1], '\]\].*', '', '')

	return s:cleanlink(join(lines, " "))
endfunction

function s:cleanlink(str)
	return tolower(substitute(trim(a:str), '\s\+', '-', 'g'))
endfunction

function minwiki#Enter()
	let link_text = s:getlink()
	if link_text == ''
		echo 'Not a link.'
	else
		call minwiki#Go(link_text)
	endif
endfunction

function minwiki#PrevPage()
	if len(t:minwiki_history) > 1
		let prev_page = t:minwiki_history[-2]
		let t:minwiki_history = t:minwiki_history[0:-3]
		call minwiki#Go(prev_page)
	else
		echo "No previous pages."
	endif
endfunction

function minwiki#NextLink()
	call search('\[\[', 'W')
endfunction

function minwiki#PrevLink()
	call search('\[\[', 'bW')
endfunction

function s:iswiki()
	if expand('%:p:h') ==? fnamemodify(g:minwiki_path, ':p:h')
		return 1
	else
		return 0
	endif
	)
endfunction
