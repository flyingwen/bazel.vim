if &cp || exists('loaded_bazel')
  finish
endif
let loaded_bazel = 1

" put bazel ralated error format in front of others, because other rules may
" mismatch message like ERROR: .../BUILD:1:1: error
let &efm = "%tRROR: %f:%l:%c: %m," . &efm
let &efm = "%tARNING: %f:%l:%c: %m," . &efm
let &efm = "%DRun bazel in %f," . &efm

fun! SetupBazelWorkspace()
    let l:root = ProjectRootGuess()
    let l:genfiles = l:root . "/bazel-genfiles"
    if (!filereadable(l:root . "/WORKSPACE"))
        return
    endif

    exec 'setlocal path+=' . l:root
    exec 'setlocal path+=' . l:genfiles

    let l:cdroot = "echo Run bazel in '" . l:root . "'; "
    let l:makeprg = "bazel build -c opt --ignore_unsupported_sandboxing $* 2>&1 \\| grep --line-buffered -v ^WARNING:"
    let &makeprg = 'sh -c "' . l:cdroot . l:makeprg . '"'
endf
au BufEnter * call SetupBazelWorkspace()
