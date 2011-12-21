
" Plugin guard {{{
if exists('g:dokuwiki_enable')
    finish
endif
let g:dokuwiki_enable = 1
" }}}
" Global variables {{{
if !exists('g:dokuwiki_enable_fold')
    let g:dokuwiki_enable_fold = 1
endif
if !exists('g:dokuwiki_enable_fold_code')
    let g:dokuwiki_enable_fold_code = 0
endif
if !exists('g:dokuwiki_enable_set_fold_text')
    let g:dokuwiki_enable_set_fold_text = 1
endif
if !exists('g:dokuwiki_inline_highlight')
    let g:dokuwiki_inline_highlight = ['vim']
endif
if !exists('g:dokuwiki_index')
    let g:dokuwiki_index = expand("$HOME") . "/.vim/wiki/start.txt"
endif
if !exists('g:dokuwiki_file_browser_plugin')
    let g:dokuwiki_file_browser_plugin = 'NERDTree'
endif

let g:dokuwiki_error = 0
" }}}
" Create and Scan DokuWIki Index {{{
python <<EOF
import os
import vim

dokuwiki_index = vim.eval('g:dokuwiki_index')
dokuwiki_dir, dokuwiki_file = os.path.split(dokuwiki_index)
dokuwiki_f_name, dokuwiki_f_ext = os.path.splitext(dokuwiki_file)

if not os.path.exists(dokuwiki_dir):
    os.makedirs(dokuwiki_dir)
elif not os.path.isdir(dokuwiki_dir):
    vim.command('echo "%s in not a directory, dokuwiki can not work!"' % dokuwiki_dir)
    vim.command('let g:dokuwiki_error = 1')

vim.command('let g:dokuwiki_dir = "%s"' % dokuwiki_dir)
vim.command('let g:dokuwiki_file_ext = "%s"' % dokuwiki_f_ext)

vim.command('autocmd BufNewFile,BufRead %s/* set ft=dokuwiki' % dokuwiki_dir)
EOF
" }}}
function! s:DokuWIkiChangeDir() " {{{
    exec 'cd ' . g:dokuwiki_dir
endfunction
" }}}
function! s:DokuWIkiOpenIndex() " {{{
    call s:DokuWIkiChangeDir()
    exec join(['vi', g:dokuwiki_index], ' ')
endfunction
" }}}
function! s:DokuWIkiOpen() " {{{
    try
        exec join([g:dokuwiki_file_browser_plugin, g:dokuwiki_dir], ' ')
        call s:DokuWIkiChangeDir()
    catch
        echo "NERDtree not found pleas. install NERDTree plugin"
    endtry
endfunction
" }}}
function! DokuWiki_Get_Fold_Level(lnum) " {{{
    let line = getline(a:lnum)

    if line =~ '^====='
        return '>1'
    elseif line =~ '^===='
        return '>2'
    elseif line =~ '^==='
        return '>3'
    elseif line =~ '^=='
        return '>4'
    elseif g:dokuwiki_enable_fold_code && line =~ '<code.\{-}>'
        return 'a1'
    elseif g:dokuwiki_enable_fold_code && line =~ '</code>'
        return 's1'
    else
        return '='
    endif
endfunction
" }}}
function! DokuWiki_Fold_Text() " {{{
    let line = getline(v:foldstart)

    if line =~ '^====='
        let level = 5
    elseif line =~ '^===='
        let level = 4
    elseif line =~ '^==='
        let level = 3
    elseif line =~ '^=='
        let level = 2
    else
        let level = ''
    endif

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    if line != ''
        let line = substitute(line, '=', '', 'g')
        let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    endif
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount) - 7
    return line . ' … '. level . repeat(" ",fillcharcount) . foldedlinecount . ' '
endfunction
" }}}

function! dokuwiki#Open() " {{{
    call s:DokuWIkiOpen()
endfunction
" }}}
function! dokuwiki#OpenIndex() " {{{
    call s:DokuWIkiOpenIndex()
endfunction
" }}}

command! -nargs=0 DokuWikiOpen      call dokuwiki#Open()
command! -nargs=0 DokuWikiOpenIndex call dokuwiki#OpenIndex()
