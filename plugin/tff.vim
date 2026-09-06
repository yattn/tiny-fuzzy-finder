if exists('g:loaded_tff')
    finish
endif
if !has('vim9script')
    echoerr 'Needs Vim version 9.0 and above'
    finish
endif
vim9script

g:loaded_tff = true

command! -nargs=0 -bar Tff call tff#Open()
