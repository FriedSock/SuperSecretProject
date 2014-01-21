ruby load '~/.vim/bundle/git-off-my-lawn/plugin/helper.rb';
ruby load '~/.vim/bundle/git-off-my-lawn/plugin/puts.rb';

function! OpenWindow()
  ruby open_window
endfunction

function! HighlightAllLines()
  sign unplace *
  ruby highlight_lines
endfunction

function! Unhighlight()
  sign unplace *
endfunction

function! SplitWindow(new_name)
  set scrollbind
  vertical 20 new
  exec 'edit ' . a:new_name
  set bt=nofile
  normal! GGdd
  set scrollbind
  syncbind
endfunction

function! ExecuteDiff()
  "Only do a diff when it is a file we are editing, not just a buffer
  if !filereadable(bufname('%'))
    return
  end

  let var=system('git ls-files ' . bufname('%') . ' --error-unmatch')
  if v:shell_error != 0
    return 1
  endif


  ruby load '~/.vim/bundle/git-off-my-lawn/plugin/helper.rb';
  let file1 = expand('%')
  let file2 = '/tmp/' . substitute(file1, '/', '', 'g') . 'funny'
  silent exec 'write! ' . file2

  let command = "ruby changedlines '" . file1 . "', '" . file2 . "'"
  exec command
endfunction

function! ColourEverything()
  if !filereadable(bufname('%'))
    return 1
  end

  let var=system('git ls-files ' . bufname('%') . ' --error-unmatch')
  if v:shell_error != 0
    return 1
  endif

  call HighlightAllLines()
endfunction

function! GetSigns()
  redir => out
  sil! exec 'sign place'
  redir END
  return out
endfunction

augroup diffing
    autocmd!

    "Note - autocommands on BufWritePost will not be executed on this file
    "because it gets reloaded on each write
    au BufWritePost * :call ColourEverything()
    au BufWinEnter * :call InitializeBuffer()
    autocmd CursorMoved * :call ExecuteDiff()
    autocmd CursorMovedI * :call ExecuteDiff()
augroup END

function! InitializeBuffer()
  let b:groups = {}
  let b:signs = {}
  let b:id = 0

  highlight new ctermbg=52 guibg=52
  call DefineSign('new', 'new')

  call ColourEverything()
endfunction
function! DefineSign(name, hlname)
  execute 'sign define ' . a:name . ' linehl=' . a:hlname

  let dict = "{ 'linehl': " . string(a:hlname) . ", 'ids': {}}"
  execute 'let b:groups.' . a:name . ' =  ' . dict
endfunction

function! PlaceSign(line_no, hl, filename)
  "TODO: Probably dont need filename
  let id = string(GetNewID())
  execute 'sign place ' . id . ' name=' . a:hl . ' line=' . a:line_no . ' file=' . a:filename
  execute 'let b:groups.' . a:hl . '.ids.'. id . '= {}'

  let sign_entry = "{'line': " . a:line_no . ", 'original_line': " . a:line_no  . ", 'group': " . string(a:hl) ." }"
  execute 'let b:signs.' . id . ' = ' . sign_entry
endfunction

"For now, this is only going to be used for unplacing 'new' ie. red signs
function! UnplaceSign(line)
  echom "Unplacing Line: " . a:line
  for e in items(b:signs)
    if string(e[1].line) ==# a:line && string(e[1].group) ==# 'new'
      echom string(e)
      "TODO break
      let id = e[0]
    end
  endfor

  execute 'sign unplace ' . id
  execute 'let group = b:signs.' . id . '.group'
  execute 'unlet b:signs.' . id
  execute 'unlet b:groups.' . group . '.ids.' . id
endfunction

function! SplitVertical()
  let new_name = bufname('%') . '-key'
  badd new_name

  split
  "TODO: Remove magic number
  resize 3

  exec 'edit ' . new_name
  set bt=nofile
  setlocal nonumber
  setlocal listchars=
  setlocal statusline=The\ Key
  ruby generate_key
endfunction

function! GetNewID()
  let b:id = b:id + 1
  return b:id
endfunction

function! MoveWrapper()
  "TODO: calculate where the new line has been added - Could do this in ruby
  call ExecuteDiff()
endfunction

function! MoveSignsDown(line)
  let line = ToNewLine(a:line)
  echom "NEW SET OF DOWN MOVING"
  for e in items(b:signs)
    if e[1].line > line
      let id = e[0]
      let new_line = e[1].line + 1
      echom id . " MOVING DOWN from " . e[1].line . " to " . new_line
      execute 'let b:signs.' . id . '.line=' . new_line
    end
  endfor
  echom "DOWN MOVING HAS FINISHED"
endfunction


function! MoveSignsUp(line)
  let line = ToNewLine(a:line)
  echom string(a:line)
  echom string(line)
  echom "NEW SET OF UP MOVING"
  for e in items(b:signs)
    if e[1].line > line
      let id = e[0]
      let new_line = e[1].line - 1
      echom id . " MOVING UP from " . e[1].line . " to " . new_line
      execute 'let b:signs.' . id . '.line=' . new_line
    end
  endfor
  echom "UP MOVING HAS FINISHED"
endfunction

"Takes a line and maps it to its location in the new state
function! ToNewLine(line)
  for e in values(b:signs)
    if e.original_line == a:line
      return e.line
    end
  endfor
endfunction

function! ReinstateSign(line)
  "Note: Need to move line up, because it was recently moved down to make way
  "for itself
  for e in items(b:signs)
    if e[1].original_line == a:line
      let id = e[0]
      let line = e[1].line - 1
      execute 'let b:signs' . '.' . id . '.line=' . line
      execute 'sign unplace ' . id
      execute 'sign place ' . id . ' name=' . e[1].group . ' line=' . line . ' file=' . bufname('%')
      return
    end
  endfor
endfunction


highlight col231 ctermbg=231  guibg=231
highlight col232 ctermbg=232  guibg=232
highlight col233 ctermbg=233  guibg=233
highlight col234 ctermbg=234  guibg=234
highlight col235 ctermbg=235  guibg=235
highlight col235 ctermbg=235  guibg=235
highlight col236 ctermbg=236  guibg=236
highlight col237 ctermbg=237  guibg=237

