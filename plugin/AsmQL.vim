" AsmQL.vim
" Brief: Display the assembly code of the current function
" Version: 0.1
" Date: 2020/04/25
" Author: Pierre-Emmanuel Patry
"
" TODO: Add user defined preference variables (linenumber, etc)

let loaded_AsmQL = 1
let s:licenseTag = "Copyright (C) \<enter>\<enter>"
let s:licenseTag = s:licenseTag . "This program is free software; you can redistribute it and/or\<enter>"
let s:licenseTag = s:licenseTag . "modify it under the terms of the GNU General Public License\<enter>"
let s:licenseTag = s:licenseTag . "as published by the Free Software Foundation; either version 2\<enter>"
let s:licenseTag = s:licenseTag . "of the License, or (at your option) any later version.\<enter>\<enter>"
let s:licenseTag = s:licenseTag . "This program is distributed in the hope that it will be useful,\<enter>"
let s:licenseTag = s:licenseTag . "but WITHOUT ANY WARRANTY; without even the implied warranty of\<enter>"
let s:licenseTag = s:licenseTag . "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\<enter>"
let s:licenseTag = s:licenseTag . "GNU General Public License for more details.\<enter>\<enter>"
let s:licenseTag = s:licenseTag . "You should have received a copy of the GNU General Public License\<enter>"
let s:licenseTag = s:licenseTag . "along with this program; if not, write to the Free Software\<enter>"
let s:licenseTag = s:licenseTag . "Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.\<enter>"


fun! AsmQL#DisasmFun(fname)

    let fn = ""
    let tpath = expand('%:p:h')

    if &filetype == "netrw"
        let atoms = split(getline('.'), '\.')
        if atoms[1] != "o"
            echo "File type is incompatible: requires object file"
            return
        endif
        let fn = atoms[0]
    else      
        let tfile = expand('%:t')
        let atoms = split(tfile, '\.')
        if len(atoms) < 2
            echo "File name incompatible"
            return
        endif
        let fn = atoms[0]
    endif

    let in = tpath . "/" . fn . ".o"

    if !filereadable(in)
        echo "Object `" . fn . ".o` file not found!"
        return
    endif
 
    let cmd = "gdb -batch -ex 'file " . in . "' -ex 'disassemble " . a:fname ."' | sed 's/.*\t//' | sed '1d;$d'"
    let dump = system(cmd)

    execute "vsplit ".a:fname."__ASM"
    normal! ggdG
    setlocal buftype=nofile
    setlocal filetype=asm
    call append(0, split(dump,'\n'))
    let header = "<" . toupper(a:fname) . ">:"
    call append(0, header)
    "setlocal number
    normal! gg

endfunction

fun! AsmQL#GetFuncName()
    let lnum = line(".")
    let col = col(".")
    let fprot = getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))
    
    let fname = ""

    let i = 0
    let c = ""
    while c != "("
        let c = strpart(fprot, i, 1)
        let i += 1
    endwhile
    let i -= 2
    let c = strpart(fprot, i, 1)
    while c == " "
        let i -= 1
        let c = strpart(fprot, i, 1)
    endwhile
    while c != " "
        let fname = c . fname
        let i -= 1
        let c = strpart(fprot, i, 1)
    endwhile
    call search("\\%" . lnum . "l" . "\\%" . col . "c")
    return fname
endfun

command! -nargs=0 Asm :call AsmQL#DisasmFun(AsmQL#GetFuncName())
