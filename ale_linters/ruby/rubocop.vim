" Author: ynonp - https://github.com/ynonp
" Description: rubocop for Ruby files

function! ale_linters#ruby#rubocop#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " <path>/_:47:14: 83:29: C: Prefer single-quoted strings when you don't
    " need string interpolation or special symbols.
    let l:pattern = '\v_:(\d+):(\d+): (.): (.+)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:text = l:match[4]
        let l:type = l:match[3]

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': index(['C', 'E'], l:type) != -1 ? 'E' : 'W',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

" Set this option to change Rubocop options.
if !exists('g:ale_ruby_rubocop_options')
    " let g:ale_ruby_rubocop_options = '--lint'
    let g:ale_ruby_rubocop_options = ''
endif

call ale#linter#Define('ruby', {
\   'name': 'rubocop',
\   'executable': 'rubocop',
\   'command': 'rubocop --format emacs --force-exclusion --stdin '
\   . g:ale_ruby_rubocop_options
\   . ' %s',
\   'callback': 'ale_linters#ruby#rubocop#Handle',
\})
