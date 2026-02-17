## Checks

* local OS X installs, R 4.2.3  (java 25.0.1, rJava 1.0.6) and 4.5.1 (openjdk 23.0.2, rJava 1.0.11)
  * `devtools::check()`
  * `devtools::check(env_vars = c('_R_CHECK_DEPENDS_ONLY_' = "true"))`
  * `devtools::check(manual = TRUE, remote = TRUE)`
* Win-Builder
  * `devtools::check_win_oldrelease()`
  * `devtools::check_win_release()`
  * `devtools::check_win_devel()`

### R CMD check results

All checks on both local installs yielded the following NOTE:

```
❯ checking for future file timestamps ... NOTE
  unable to verify current time
```

Additionally, the third check obtained the following NOTE:

```
❯ checking CRAN incoming feasibility ... NOTE
  Maintainer: ‘Jason Cory Brunson <cornelioid@gmail.com>’
  
  New submission
```

### WinBuilder

There were no ERRORs or WARNINGs.

All checks resulted in 1 NOTE, about several possibly misspelled words, though these are in fact spelled correctly:
"Hajij", "Oudot", "Reeb", "ReebGraphPairing", "Rosen", and "rJava".

## Downstream dependencies

As this is an initial submission, there are no dependencies to check.
