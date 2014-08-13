## How to jump in on rOpenSci projects

This was made by/with:

* Github API via custom functions, see `jumpin.R`
* Sorting for the table comes from [Sortable](http://github.hubspot.com/sortable/)
* Sparkline plots come from [jQuery Sparklines](http://omnipotent.net/jquery.sparkline/#s-about)
* Bootstrap table styling

To create the summary table:

1. Define the packages you want to collect data on in the `pkgs` variable at the top.
2. If you're not interested in rOpenSci repos, do change the `owner` param throughout.
3. Load all the functions.
4. Run `out <- lapply(pkgs, for_each_pkg)`
5. Generate html and view it.
