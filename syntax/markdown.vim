" Vim syntax file
" Language:     Markdown
" Maintainer:   Tim Pope <vimNOSPAM@tpope.org>
" Filenames:    *.markdown
" Last Change:  2013 May 30

if exists("b:current_syntax")
  finish
endif

if !exists('main_syntax')
  let main_syntax = 'markdown'
endif

runtime! syntax/html.vim
unlet! b:current_syntax

if !exists('g:markdown_fenced_languages')
  let g:markdown_fenced_languages = []
endif
for s:type in map(copy(g:markdown_fenced_languages),'matchstr(v:val,"[^=]*$")')
  if s:type =~ '\.'
    let b:{matchstr(s:type,'[^.]*')}_subtype = matchstr(s:type,'\.\zs.*')
  endif
  exe 'syn include @markdownHighlight'.substitute(s:type,'\.','','g').' syntax/'.matchstr(s:type,'[^.]*').'.vim'
  unlet! b:current_syntax
endfor
unlet! s:type

" Let the user determine which markers to conceal and which not to conceal:
"   #: headings, *: bullets, d: id declarations, l: links, a: automatic links,
"   i: italic text, b: bold text, B: bold and italic text, c: code fragments,
"   e: common HTML entities, s: escapes
if !has("conceal")
  let s:markdown_conceal = ''
elseif !exists("g:markdown_conceal")
  let s:markdown_conceal = '#*dlaibBces'
else
  let s:markdown_conceal = g:markdown_conceal
endif

" Decide whether to render list bullets as a proper bullet character.
let s:conceal_bullets = (&encoding == 'utf-8' && s:markdown_conceal =~ '*')

syn sync minlines=10
syn case ignore

syn match markdownValid '[<>]\c[a-z/$!]\@!'
syn match markdownValid '&\%(#\=\w*;\)\@!'

syn match markdownLineStart "^[<@]\@!" nextgroup=@markdownBlock,htmlSpecialChar

syn cluster markdownBlock contains=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6,markdownBlockquote,markdownListMarker,markdownOrderedListMarker,markdownCodeBlock,markdownRule
syn cluster markdownInline contains=markdownLineBreak,markdownLinkText,markdownItalic,markdownBold,markdownCode,markdownEscape,@htmlTop,markdownError

syn match markdownH1 "^.\+\n=\+$" contained contains=@markdownInline,markdownHeadingRule,markdownAutomaticLink
syn match markdownH2 "^.\+\n-\+$" contained contains=@markdownInline,markdownHeadingRule,markdownAutomaticLink

syn match markdownHeadingRule "^[=-]\+$" contained

if s:markdown_conceal =~ '#'
  syn region markdownH1 matchgroup=markdownHeadingDelimiter start="##\@!\s*"      end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
  syn region markdownH2 matchgroup=markdownHeadingDelimiter start="###\@!\s*"     end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
  syn region markdownH3 matchgroup=markdownHeadingDelimiter start="####\@!\s*"    end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
  syn region markdownH4 matchgroup=markdownHeadingDelimiter start="#####\@!\s*"   end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
  syn region markdownH5 matchgroup=markdownHeadingDelimiter start="######\@!\s*"  end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
  syn region markdownH6 matchgroup=markdownHeadingDelimiter start="#######\@!\s*" end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
else
  syn region markdownH1 matchgroup=markdownHeadingDelimiter start="##\@!"      end="#*\s*$" keepend oneline contains=@markdownInline contained
  syn region markdownH2 matchgroup=markdownHeadingDelimiter start="###\@!"     end="#*\s*$" keepend oneline contains=@markdownInline contained
  syn region markdownH3 matchgroup=markdownHeadingDelimiter start="####\@!"    end="#*\s*$" keepend oneline contains=@markdownInline contained
  syn region markdownH4 matchgroup=markdownHeadingDelimiter start="#####\@!"   end="#*\s*$" keepend oneline contains=@markdownInline contained
  syn region markdownH5 matchgroup=markdownHeadingDelimiter start="######\@!"  end="#*\s*$" keepend oneline contains=@markdownInline contained
  syn region markdownH6 matchgroup=markdownHeadingDelimiter start="#######\@!" end="#*\s*$" keepend oneline contains=@markdownInline contained
endif

syn match markdownBlockquote ">\%(\s\=\|$\)" contained nextgroup=@markdownBlock

syn region markdownCodeBlock start="    \|\t" end="$" contained

" TODO: real nesting
syn match markdownListMarker "\%(\t\| \{0,4\}\)[-*+]\%(\s\+\S\)\@=" contained
syn match markdownOrderedListMarker "\%(\t\| \{0,4}\)\<\d\+\.\%(\s\+\S\)\@=" contained

if s:conceal_bullets
  syntax match markdownPrettyListMarker /[-*+]/ conceal cchar=• contained containedin=markdownListMarker
endif

syn match markdownRule "\* *\* *\*[ *]*$" contained
syn match markdownRule "- *- *-[ -]*$" contained

syn match markdownLineBreak " \{2,\}$"

if s:markdown_conceal =~# 'd'
  syn region markdownIdDeclaration matchgroup=markdownLinkDelimiter start="^ \{0,3\}!\=\[" end="\]\ze:" oneline keepend nextgroup=markdownUrl skipwhite concealends
else
  syn region markdownIdDeclaration matchgroup=markdownLinkDelimiter start="^ \{0,3\}!\=\[" end="\]:" oneline keepend nextgroup=markdownUrl skipwhite
endif

syn match markdownUrl "\S\+" nextgroup=markdownUrlTitle skipwhite contained
syn region markdownUrl matchgroup=markdownUrlDelimiter start="<" end=">" oneline keepend nextgroup=markdownUrlTitle skipwhite contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+"+ end=+"+ keepend contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+'+ end=+'+ keepend contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+(+ end=+)+ keepend contained

if s:markdown_conceal =~# 'l'
  syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" keepend nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart concealends
  syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained conceal
  syn region markdownId matchgroup=markdownIdDelimiter start="\s*\[" end="\]" keepend contained conceal
else
  syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" keepend nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart
  syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained
  syn region markdownId matchgroup=markdownIdDelimiter start="\[" end="\]" keepend contained
endif

if s:markdown_conceal =~# 'a'
  syn region markdownAutomaticLink matchgroup=markdownUrlDelimiter start="<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=" end=">" keepend oneline concealends
else
  syn region markdownAutomaticLink matchgroup=markdownUrlDelimiter start="<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=" end=">" keepend oneline
endif

let s:concealends = has('conceal') ? 'concealends' : ''
function! s:InlineRegionPatterns(start, end)
  " generate a new start pattern that matches the given start, followed by
  " the end after some text, without any blank lines in between.
  let l:start = '\%(' . a:start . '\)\ze\%(.\|\n\%(>\s\=\)*\s*[^> \t]\@=\)\{-}\%(' . a:end . '\)'
  " assume that the '"' character can be used as a delimiter
  return 'start="' . l:start . '" end="' . a:end . '"'
endfunction
exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter' s:InlineRegionPatterns('\%(\S\@<=\*\|\*\S\@=\)\ze\%(.\|\n\s*\S\@=\)\{-}', '\S\@<=\*\|\*\S\@=') 'keepend contains=markdownLineStart' s:concealends
exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter' s:InlineRegionPatterns('\S\@<=_\|_\S\@=', '\S\@<=_\|_\S\@=') 'keepend contains=markdownLineStart' s:concealends
exe 'syn region markdownBold matchgroup=markdownBoldDelimiter' s:InlineRegionPatterns('\S\@<=\*\*\|\*\*\S\@=', '\S\@<=\*\*\|\*\*\S\@=') 'keepend contains=markdownLineStart,markdownItalic' s:concealends
exe 'syn region markdownBold matchgroup=markdownBoldDelimiter' s:InlineRegionPatterns('\S\@<=__\|__\S\@=', '\S\@<=__\|__\S\@=') 'keepend contains=markdownLineStart,markdownItalic' s:concealends
exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter' s:InlineRegionPatterns('\S\@<=\*\*\*\|\*\*\*\S\@=', '\S\@<=\*\*\*\|\*\*\*\S\@=') 'keepend contains=markdownLineStart' s:concealends
exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter' s:InlineRegionPatterns('\S\@<=___\|___\S\@=', '\S\@<=___\|___\S\@=') 'keepend contains=markdownLineStart' s:concealends

if s:markdown_conceal =~# 'c'
  exe 'syn region markdownCode matchgroup=markdownCodeDelimiter' s:InlineRegionPatterns('`\%(``\)\@!', '`') 'keepend contains=markdownLineStart' s:concealends
  exe 'syn region markdownCode matchgroup=markdownCodeDelimiter' s:InlineRegionPatterns('`\@1<!```\@! \=', ' \=``') 'keepend contains=markdownLineStart' s:concealends
  " experimentally, markdown code fences do not require match start/end markers,
  " they only care that the start/end markers are independently valid.
  syn region markdownFencedCode matchgroup=markdownCodeFence start="\s*```.*$" start="\s*\~\{3}.*$" end="^\s*`\{3,}\ze\s*$" end="^\s*\~\{3,}\ze\s*$" contained keepend concealends
else
  exe 'syn region markdownCode matchgroup=markdownCodeDelimiter' s:InlineRegionPatterns('`\%(``\)\@!', '`') 'keepend contains=markdownLineStart'
  exe 'syn region markdownCode matchgroup=markdownCodeDelimiter' s:InlineRegionPatterns('`\@1<!```\@! \=', ' \=``') 'keepend contains=markdownLineStart'
  syn region markdownFencedCode matchgroup=markdownCodeFence start="\s*```.*$" start="\s*\~\{3}.*$" end="^\s*`\{3,}\ze\s*$" end="^\s*\~\{3,}\ze\s*$" contained keepend
endif
syn cluster markdownBlock add=markdownFencedCode

syn match markdownFootnote "\[^[^\]]\+\]"
syn match markdownFootnoteDefinition "^\[^[^\]]\+\]:"

if main_syntax ==# 'markdown'
  for s:type in g:markdown_fenced_languages
    let s:type = matchstr(s:type,'[^=]*$')
    let s:regionName = 'markdownHighlight'.substitute(s:type,'\..*','','')
    if s:markdown_conceal =~# 'c'
      exe 'syn region' s:regionName ' matchgroup=markdownCodeDelimiter start="\s*```\s*'.s:type.'\>.*$" end="^\s*```\ze\s*$" keepend contained contains=@markdownHighlight'.substitute(s:type,'\.','','g').' concealends'
    else
      exe 'syn region' s:regionName ' matchgroup=markdownCodeDelimiter start="\s*```\s*'.s:type.'\>.*$" end="^\s*```\ze\s*$" keepend contained contains=@markdownHighlight'.substitute(s:type,'\.','','g')
    endif
    exe 'syn cluster markdownBlock add='.s:regionName
  endfor
  unlet! s:type
  unlet! s:regionName
endif

syn match markdownEscape "\\[][\\`*_{}()#+.!-]"
if s:markdown_conceal =~# 's'
  syn match markdownEscapeMarker "\\" contained containedin=markdownEscape conceal
endif

syn match markdownError "\w\@<=_\w\@="

if s:markdown_conceal =~# 'e'
  " There's no equivalent for these without the conceal feature.
  syntax match markdownLessThan /&lt;/ conceal cchar=<
  syntax match markdownGreaterThan /&gt;/ conceal cchar=>
  syntax match markdownAmpersand /&amp;/ conceal cchar=&
endif

if s:markdown_conceal =~# '[*e]'
  " The "conceal cchar=..." characters (list bullets and HTML entities) look
  " really crappy by default because of the default styling for "concealed"
  " characters. We want it to look more or less like regular text:
  hi link Conceal htmlTagName
endif

hi def link markdownH1                    htmlH1
hi def link markdownH2                    htmlH2
hi def link markdownH3                    htmlH3
hi def link markdownH4                    htmlH4
hi def link markdownH5                    htmlH5
hi def link markdownH6                    htmlH6
hi def link markdownHeadingRule           markdownRule
hi def link markdownHeadingDelimiter      Delimiter
hi def link markdownOrderedListMarker     markdownListMarker
hi def link markdownListMarker            htmlTagName
hi def link markdownBlockquote            Comment
hi def link markdownRule                  PreProc

hi def link markdownFootnote              Typedef
hi def link markdownFootnoteDefinition    Typedef

hi def link markdownLinkText              htmlLink
hi def link markdownIdDeclaration         Typedef
hi def link markdownId                    Type
hi def link markdownAutomaticLink         markdownUrl
hi def link markdownUrl                   Float
hi def link markdownUrlTitle              String
hi def link markdownIdDelimiter           markdownLinkDelimiter
hi def link markdownUrlDelimiter          htmlTag
hi def link markdownUrlTitleDelimiter     Delimiter

hi def link markdownItalic                htmlItalic
hi def link markdownItalicDelimiter       markdownItalic
hi def link markdownBold                  htmlBold
hi def link markdownBoldDelimiter         markdownBold
hi def link markdownBoldItalic            htmlBoldItalic
hi def link markdownBoldItalicDelimiter   markdownBoldItalic
hi def link markdownCodeDelimiter         Delimiter
hi def link markdownCodeFence             markdownCodeDelimiter

hi def link markdownEscape                Special
hi def link markdownError                 Error

if s:conceal_bullets
  hi def link markdownPrettyListMarker markdownListMarker
endif

if s:markdown_conceal =~# 'e'
  hi def link markdownLessThan markdownListMarker
  hi def link markdownGreaterThan markdownListMarker
  hi def link markdownAmpersand markdownListMarker
endif

let b:current_syntax = "markdown"
if main_syntax ==# 'markdown'
  unlet main_syntax
endif

" vim:set sw=2:
