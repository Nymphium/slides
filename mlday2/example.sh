#!/bin/bash

opam switch 4.06.1 -q && eval $(opam env)

nvim example.eff +'set ft=ocaml' -c SyntasticToggle -c 'sp term://rlwrap eff'

opam switch 4.06.1+multicore+trunk -q && eval $(opam env)
