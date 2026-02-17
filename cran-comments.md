## Checks

* local OS X installs, R 4.2.3 and 4.5.1
  * `devtools::check()`
  * `devtools::check(env_vars = c('_R_CHECK_DEPENDS_ONLY_' = "true"))`
  * `devtools::check(manual = TRUE, remote = TRUE)`
* Win-Builder
  * `devtools::check_win_oldrelease()`
  * `devtools::check_win_release()`
  * `devtools::check_win_devel()`

### R CMD check results

On the local install with R 4.2.3 (Java , rJava ), there was only one (consistent) NOTE:

```
❯ checking for future file timestamps ... NOTE
  unable to verify current time
```

On the local install with R 4.5.1 (, rJava 1.0.11), there were no ERRORs, WARNINGs, or NOTEs.

### WinBuilder

There were no ERRORs or WARNINGs.

There was consistently 1 NOTE, about several possibly misspelled words, though these are in fact spelled correctly:
"Hajij", "Oudot", "Reeb", "ReebGraphPairing", "Rosen", and "rJava".

## Downstream dependencies

As this is an initial submission, there are no dependencies to check.
