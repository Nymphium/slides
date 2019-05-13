how do you implement algebraic effects and handlers?
===

- さまざまなruntime
    - as libraries
    - as languages' primitive

    how to represent algebraic effects?

- free monad
- delimited continuation
- coroutines
- other
    + n-barreled CPS
    + VM and rich ops

- performance (予想)
    VM > delimited continuation >= coroutines, fiber >= free monad > n-barreled CPS

----


