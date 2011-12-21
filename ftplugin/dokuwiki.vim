
" Setup Syntax Highlighting {{{
let b:current_syntax = ''
unlet b:current_syntax
syntax include @DOKUWIKI syntax/dokuwiki.vim

"let b:current_syntax = ''
"unlet b:current_syntax
"syntax include @CODE syntax/dokuwiki-code.vim
"syntax region CodeEmbedded matchgroup=Snip start='<code>' end='</code>' containedin=@DOKUWIKI contains=@CODE


"let b:current_syntax = ''
"unlet b:current_syntax
"syntax region CodeEmbedded matchgroup=Snip start='<code .{-}>' end='</code>' containedin=@DOKUWIKI contains=@CODE

python << EOF
langs_list = vim.eval('g:dokuwiki_inline_highlight')

for lang in langs_list:
    LANG = lang.upper()

    vim.command("let b:current_syntax = ''")

    vim.command("unlet b:current_syntax")

    vim.command("syntax include @%s syntax/%s.vim" % (LANG, lang))

    cmd  = "syntax region %sEmbedded matchgroup=Snip start='<code %s>' end='</code>'" % (LANG, lang)
    cmd += " containedin=@DOKUWIKI contains=@%s" % (LANG)
    vim.command(cmd)

langs_str = str(langs_list).replace(', ', '.')
langs_str = langs_str.replace('\'', '')

vim.command("hi link Snip SpecialComment")
vim.command("let b:current_syntax = 'dokuwiki%s.'" % langs_str.replace)
EOF
" }}}
" Active Fold {{{
if g:dokuwiki_enable_fold
    setlocal foldmethod=expr
    setlocal foldexpr=DokuWiki_Get_Fold_Level(v:lnum)
endif

if g:dokuwiki_enable_set_fold_text
    setlocal foldtext=DokuWiki_Fold_Text()
endif
" }}}
