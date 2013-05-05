" vim: set et fdm=marker ft=vim sts=2 sw=2 ts=2 :
" NEW BSD LICENSE {{{
" Copyright (c) 2013, Jagua.
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without modification,
" are permitted provided that the following conditions are met:
"
"     1. Redistributions of source code must retain the above copyright notice,
"        this list of conditions and the following disclaimer.
"     2. Redistributions in binary form must reproduce the above copyright notice,
"        this list of conditions and the following disclaimer in the documentation
"        and/or other materials provided with the distribution.
"     3. The names of the authors may not be used to endorse or promote products
"        derived from this software without specific prior written permission.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
" ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
" WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
" IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
" INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
" BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
" DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
" LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
" OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
" THE POSSIBILITY OF SUCH DAMAGE.
" }}}


scriptencoding utf-8


let s:save_cpo = &cpo
set cpo&vim


let s:unite_toho = {
\ 'name' : 'toho',
\ 'description' : 'Unite toho',
\ 'default_action' : {'command' : 'th_command'},
\ 'action_table' : {
\   'th_command' : {
\     'description' : 'th**.exe',
\     'is_selectable' : 1,
\   },
\   'custom_command' : {
\     'description' : 'custom.exe',
\     'is_selectable' : 1,
\   },
\   'vpatch_command' : {
\     'description' : 'vpatch.exe',
\     'is_selectable' : 1,
\   },
\ },
\}


let s:toho = []


if !exists('g:unite_toho_lang_hack') "{{{
  let g:unite_toho_lang_hack = 1
endif "}}}


function! s:has_vimproc() "{{{
  if !exists('s:exists_vimproc')
    try
      call vimproc#version()
      let s:exists_vimproc = 1
    catch
      let s:exists_vimproc = 0
    endtry
  endif
  return s:exists_vimproc
endfunction "}}}


function! s:spawn(cmd) "{{{
  if has('unix') && g:unite_toho_lang_hack
    let $LANG="ja_JP.UTF-8"
  endif
  if s:has_vimproc()
    call vimproc#system_gui(a:cmd)
  else
    call system(a:cmd)
  endif
endfunction "}}}


function! s:unite_toho.action_table.th_command.func(candidates) "{{{
  for candidate in a:candidates
    execute 'lcd' fnameescape(iconv(candidate.source__command.dirname, &tenc, &enc))
    call s:spawn(candidate.source__command.th_command)
  endfor
endfunction "}}}


function! s:unite_toho.action_table.custom_command.func(candidates) "{{{
  for candidate in a:candidates
    execute 'lcd' fnameescape(iconv(candidate.source__command.dirname, &tenc, &enc))
    call s:spawn(candidate.source__command.custom_command)
  endfor
endfunction "}}}


function! s:unite_toho.action_table.vpatch_command.func(candidates) "{{{
  for candidate in a:candidates
    let s:vpatch_exe = 'vpatch.exe'
    if has_key(candidate.source__command, 'vpatch_command')
      let s:vpatch_exe = candidate.source__command.vpatch_command
    endif
    execute 'lcd' fnameescape(iconv(candidate.source__command.dirname, &tenc, &enc))
    call s:spawn(s:vpatch_exe)
  endfor
endfunction "}}}


function! s:toho_menu() "{{{
  for conf in g:unite_toho_config
    if !has_key(conf, 'vpatch_command')
      let conf.vpatch_command = 'vpatch.exe'
    endif
    if !has_key(conf, 'custom_command')
      let conf.custom_command = 'custom.exe'
    endif
    call add(s:toho, conf)
  endfor
endfunction "}}}


function! s:unite_toho.gather_candidates(args, context) "{{{
  if empty(s:toho) | call s:toho_menu() | endif
  return map(copy(s:toho), '{
  \ "word" : iconv(v:val.title, &tenc, &enc),
  \ "source" : "toho",
  \ "kind" : "command",
  \ "source__command" : v:val,
  \ }')
endfunction "}}}


call unite#define_source(s:unite_toho)


let &cpo = s:save_cpo
unlet s:save_cpo

