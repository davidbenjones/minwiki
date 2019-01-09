function minwiki#Go(page_name) 
	let page_path = g:minwiki_path . a:page_name

	" FIX: Actually check if it's a URL instead of this shit.
	if match(a:page_name, 'http') != -1
		echo "Cannot follow URL."
		return
	endif

	if @% == ""
		exe "edit " . page_path	
	elseif s:iswiki()
		write
		exe "edit " . page_path
	else
		exe "tab drop " . page_path
	endif

	if !exists('w:minwiki_history')
		let w:minwiki_history = []
	endif

	call add(w:minwiki_history, a:page_name)
endfunction

function s:getlink()
	let current_character = matchstr(getline('.'), '\%'.col('.').'c.')
	if current_character == '['
		normal! l
		let return_cursor = 'normal! h'
	elseif current_character == ')'
		normal! h
		let return_cursor = 'normal! l'
	endif

	let end_pos = searchpairpos('\[','\](',')','ncW')
	let end_column = end_pos[1]
	let end_line = end_pos[0]

	let start_pos = searchpairpos('\[','\](',')','ncbW')
	let start_column = start_pos[1]
	let start_line = start_pos[0]

	if exists('return_cursor')
		exec return_cursor
	endif

	" if the braces don't match, return an empty string
	if start_line == 0 || end_line == 0
		return ''
	endif

	let lines = getline(start_line,end_line)

	" trim excess at start and end
	let lines[0] = lines[0][start_column-1:]
	let lines[-1] = substitute(lines[-1], ').*', '', '')
	let text = join(lines, ' ')
	let text = substitute(text, '[^\]]*\](', '', '')

	return s:cleanlink(text)
endfunction

function s:createlink()
	let current_character = matchstr(getline('.'), '\%'.col('.').'c.')
	if current_character == ']'
		normal! h
		let return_cursor = 'normal! l'
	elseif current_character == '['
		normal! l
		let return_cursor = 'normal! h'
	endif

	let end_pos = searchpairpos('\[','','\]','ncW')
	let end_column = end_pos[1]
	let end_line = end_pos[0]

	let start_pos = searchpairpos('\[','','\]','ncbW')
	let start_column = start_pos[1]
	let start_line = start_pos[0]

	if exists('return_cursor')
		exec return_cursor
	endif

	if start_line == 0 || end_line == 0
		let cursor_word = expand('<cword>')
		let new_text = '[' . cursor_word . ']'
		exec 'normal! ciw' . new_text
		return 0
	endif

	let original_lines = getline(start_line,end_line)
	let lines = copy(original_lines)
	" STEPS:
	"	1. Get the text inside the brackets.
	"	2. Append the link in parentheses

	" get text inside of brackets
	let lines[0] = lines[0][start_column:]
	let lines[-1] = substitute(lines[-1], '\].*', '', '')

	let clean_link = s:cleanlink(join(lines, ' '))

	" prepare new text and replace with link
	let original_lines[-1] = original_lines[-1][0:end_column-1] . '(' . clean_link . '.md)' . original_lines[-1][end_column:]

	call setline(start_line,original_lines)
	
	echo 'New link: ' . clean_link . '.md'
endfunction

function s:cleanlink(str)
	return tolower(substitute(trim(a:str), '\s\+', '-', 'g'))
endfunction

function minwiki#Enter()
	let link_text = s:getlink()
	if link_text == ''
		call s:createlink()
	else
		call minwiki#Go(link_text)
	endif
endfunction

function minwiki#PrevPage()
	if len(w:minwiki_history) > 1
		let prev_page = w:minwiki_history[-2]
		let w:minwiki_history = w:minwiki_history[0:-3]
		call minwiki#Go(prev_page)
	else
		echo "No previous pages."
	endif
endfunction

" FIX: ignore brackets in inline code or code blocks

function minwiki#NextLink(count)
	let i = a:count
	while i
		call search('\[\([^\]]\|\n\)*\](\([^)]\|\n\)*)', '')
		let i = i - 1
	endwhile
endfunction

function minwiki#PrevLink(count)
	let i = a:count
	while i
		call search('\[\([^\]]\|\n\)*\](\([^)]\|\n\)*)', 'b')
		let i = i - 1
	endwhile
endfunction

function s:iswiki()
	if expand('%:p:h') ==? fnamemodify(g:minwiki_path, ':p:h')
		return 1
	else
		return 0
	endif
endfunction
