ruby load '~/.vim/bundle/git-off-my-lawn/plugin/helper.rb';

function! OpenWindow()
  ruby open_window
endfunction

function! HighlightNow()
  sign unplace *
  ruby highlight_now
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

function! DiffMe()
  "Only do a diff when it is a file we are editing, not just a buffer
  if !filereadable(bufname('%'))
    return
  end

  call RemoveRed()

  ruby load '~/.vim/bundle/git-off-my-lawn/plugin/helper.rb';
  let file1 = expand('%')
  let file2 = '/tmp/' . substitute(file1, '/', '', 'g') . 'funny'
  silent exec 'write! ' . file2

  let command = "ruby changedlines '" . file1 . "', '" . file2 . "'"
  exec command
endfunction

function! <SID>ColourEverything()
  if !filereadable(bufname('%'))
    return
  end
  call HighlightNow()
  call DiffMe()
endfunction

function! GetSigns()
  redir => out
  sil! exec 'sign place'
  redir END
  return out
endfunction

function! RemoveRed()
  let var = GetSigns()
  let command =  'ruby remove_red_lines "' . var . '"'
  exec command
endfunction

augroup diffing
    autocmd!

    "Note - autocommands on BufWritePost will not be executed on this file
    "because it gets reloaded on each write
    call <SID>ColourEverything()
    au BufWritePost * :call <SID>ColourEverything()
    autocmd CursorMoved * :call DiffMe()
    autocmd CursorMovedI * :call DiffMe()
augroup END

