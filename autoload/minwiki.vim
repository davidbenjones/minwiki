function minwiki#Go(...) 
	if a:0 == 0
		let page_name = s:input('Go to wiki page: ', '')
		if match(page_name,'^\s*$') > -1
			echo 'No page given.'
			return
		elseif match(page_name,'..*\.md$') == -1
			let page_name = page_name . '.md'
		endif
	else
		let page_name = a:1
	endif

	if s:urltype(page_name) !=? 'wiki'
		echo 'Cannot follow link.'
		return
	endif

	let page_path = g:minwiki_path . page_name

	" current buffer is empty
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

	call add(w:minwiki_history, page_name)
endfunction

function minwiki#AutocompletePage(A,L,P)
	return map(glob(g:minwiki_path . a:A . '*', 0, 1),"fnamemodify(v:val,':t')")
endfunction

function s:input(prompt,default)
	call inputsave()
	let temp = input(a:prompt, a:default, 'customlist,minwiki#AutocompletePage')
	call inputrestore()
	redraw
	return temp
endfunction

function s:urltype(url)
	if match(a:url, '^https\?://') != -1
		return 'web'
	elseif match(a:url, '.*\.md$') != -1
		return 'wiki'
	elseif match(a:url,'^\s*$') > -1
		return 'blank'
	endif
	return 'other'
endfunction

" escape for magic mode
function s:regexmagicescape(string, other_characters)
	" use a:other_characters to add delimiter
	return escape(a:string, '*^$.&~\' . a:other_characters)
endfunction

function minwiki#Rename(...)
	if a:0 == 0
		let old_name = s:input('Rename wiki page: ', s:getlink())
	else
		let old_name = a:1
	endif

	let old_urltype = s:urltype(old_name)
	if old_urltype ==# 'blank'
		echon 'No page to rename.'
		return 0
	elseif old_urltype !=# 'wiki'
		echon 'Not a wiki link.'
		return 0
	endif

	if a:0 < 1
		let new_name = s:input('Rename ''' . tolower(old_name) . ''' to: ', '')
	else
		let new_name = a:2
	endif

	let new_urltype = s:urltype(new_name)
	if new_urltype ==# 'blank'
		echon 'No page given.'
		return 0
	elseif new_urltype !=# 'wiki'
		echon 'Target not a wiki link.'
		return 0
	endif

	return s:renamepage(old_name,new_name)
endfunction

function s:renamepage(old_name,new_name)
	let l:old_name = tolower(a:old_name)
	let l:new_name = tolower(a:new_name)

	if !empty(glob(g:minwiki_path . l:new_name))
		echo 'Cannot rename ''' . l:old_name . ''' to ''' . l:new_name .
			\ '''. Target already exists.'
		return 1
	endif

	echohl WarningMsg
	echon 'Rename ''' . l:old_name . ''' to ''' . l:new_name . '''? (Y)es, [N]o: '
	echohl None
	let confirm_rename = nr2char(getchar())
	
	if !(confirm_rename ==? 'y')
		echo 'Did not rename ''' . l:old_name . '''.'
		return 0
	endif

	let option_hidden = &hidden
	set hidden

	let current_buffer = bufnr('%')
	let close_buffers = []

	if filereadable(fnamemodify(g:minwiki_path . l:old_name, ':p'))
		if bufnr(g:minwiki_path . l:old_name) == -1
			call add(close_buffers,g:minwiki_path . l:old_name)
			call add(close_buffers,g:minwiki_path . l:new_name)
		endif
		exe 'silent! edit' g:minwiki_path . l:old_name
		exe 'silent! saveas' g:minwiki_path . l:new_name
		call delete(fnamemodify(g:minwiki_path . l:old_name,':p'))
	endif

	let wiki_files = glob(g:minwiki_path . '*', 0, 1)
	let total_files = len(wiki_files)

	let msgprefix = 'Renaming ' . l:old_name . ' to ' . l:new_name . ': '
	let files_processed = 0

	for file_name in wiki_files
		if bufnr(file_name) == -1
			call add(close_buffers,file_name)
		endif

		exe 'silent! edit' file_name
		exe '%s/\m\[[^\]]*\](\zs' . s:regexmagicescape(l:old_name,'/') . '\ze)' .
			\ '/' . escape(l:new_name,'&\/') . '/gie'
		exe 'silent! write' file_name

		let files_processed += 1
		call s:printprogress(files_processed,total_files,msgprefix)
	endfor

	exe 'buffer' current_buffer

	for file_name in close_buffers
		exe 'bwipeout' file_name
	endfor

	let &hidden = option_hidden

	return 0
endfunction

function s:printprogress(part,total,prefix)
	let length = 12
	let percent = float2nr(1.0 * a:part / a:total * length)
	let padding = len(a:total) - len(a:part)
	echon a:prefix . '[' . repeat('=',percent) . repeat(' ',length-percent) . '] '
		\ . repeat(' ',padding) . a:part . '/' . a:total
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
