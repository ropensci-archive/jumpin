## setup, list packages library('github')
library("devtools")
library("httr")
library("whisker")
library("yaml")
## Define your packages
pkgs <- c("alm", "AntWeb", "bmc", "bold", "clifro", "dependencies", "ecoengine", 
    "ecoretriever", "elastic", "elife", "floras", "fulltext", "geonames", "gistr", 
    "jekyll-knitr", "knitr-ruby", "mocker", "neotoma", "plotly", "rAltmetric", "rAvis", 
    "rbhl", "rbison", "rcrossref", "rdatacite", "rdryad", "rebird", "rentrez", "reol", 
    "reproducibility-guide", "rfigshare", "rfishbase", "rfisheries", "rflybase", 
    "rgauges", "rgbif", "rglobi", "rhindawi", "rImpactStory", "rinat", "RMendeley", 
    "rmetadata", "RNeXML", "rnoaa", "rnpn", "rotraits", "rplos", "rsnps", "rspringer", 
    "rvertnet", "rWBclimate", "solr", "spocc", "taxize", "togeojson", "treeBASE", 
    "ucipp", "testdat", "git2r")
## Functions
github_auth <- function(appname = getOption("gh_appname"), key = getOption("gh_id"), 
    secret = getOption("gh_secret")) {
    if (is.null(getOption("gh_token"))) {
        myapp <- oauth_app(appname, key, secret)
        token <- oauth2.0_token(oauth_endpoints("github"), myapp)
        options(gh_token = token)
    } else {
        token <- getOption("gh_token")
    }
    return(token)
}
make_url <- function(x, y, z) {
    sprintf("https://api.github.com/repos/%s/%s/%s", x, y, z)
}
process_result <- function(x) {
    stop_for_status(x)
    if (!x$headers$`content-type` == "application/json; charset=utf-8") 
        stop("content type mismatch")
    tmp <- content(x, as = "text")
    jsonlite::fromJSON(tmp, flatten = TRUE)
}
ifemptyelse <- function(x, y) {
    if (length(x) == 0) 
        data.frame(NULL) else x[, y]
}
# gh_rate_limit()
gh_rate_limit <- function(...) {
    token <- github_auth()
    req <- GET("https://api.github.com/rate_limit", config = c(token = token, ...))
    process_result(req)
}
# gh_forks('ropensci', 'taxize')
gh_forks <- function(owner = "ropensci", repo, ...) {
    token <- github_auth()
    req <- GET(make_url(owner, repo, "forks"), config = c(token = token, ...))
    process_result(req)
}
# gh_issues('ropensci', 'taxize')
gh_issues <- function(owner = "ropensci", repo, query = list(), ...) {
    token <- github_auth()
    req <- GET(make_url(owner, repo, "issues"), query = ct(query), config = c(token = token, 
        ...))
    process_result(req)
}
ct <- function(l) Filter(Negate(is.null), l)
# gh_stars('ropensci', 'taxize')
gh_stars <- function(owner = "ropensci", repo, ...) {
    token <- github_auth()
    req <- GET(make_url(owner, repo, "stargazers"), config = c(token = token, ...))
    process_result(req)
}
# gh_milestones('ropensci', 'taxize')
gh_milestones <- function(owner = "ropensci", repo, ...) {
    token <- github_auth()
    req <- GET(make_url(owner, repo, "milestones"), config = c(token = token, ...))
    process_result(req)
}
# gh_pulls('ropensci', 'taxize')
gh_pulls <- function(owner = "ropensci", repo, ...) {
    token <- github_auth()
    req <- GET(make_url(owner, repo, "pulls"), config = c(token = token, ...))
    process_result(req)
}
# gh_contributors('ropensci', 'taxize')
gh_contributors <- function(owner = "ropensci", repo, ...) {
    token <- github_auth()
    req <- GET(make_url(owner, repo, "contributors"), config = c(token = token, ...))
    process_result(req)
}
# gh_branches('ropensci', 'taxize')
gh_branches <- function(owner = "ropensci", repo, ...) {
    token <- github_auth()
    req <- GET(make_url(owner, repo, "branches"), config = c(token = token, ...))
    process_result(req)
}
# gh_commit_activity('ropensci', 'taxize')
gh_commit_activity <- function(owner = "ropensci", repo, ...) {
    token <- github_auth()
    req <- GET(make_url(owner, repo, "stats/commit_activity"), config = c(token = token, 
        ...))
    process_result(req)
}
gh_check_file <- function(owner = "ropensci", repo, ...) {
    token <- github_auth()
    req <- GET(make_url(owner, repo, "contents/DESCRIPTION"), config = c(token = token, 
        ...))
    if (!req$headers$status == "200 OK") {
        NA
    } else {
        cts <- process_result(req)$content
        gsub("\\s+", "", parse_desc_file(cts))
    }
}
parse_desc_file <- function(x) {
    tmp <- gsub("\n\\s+", "\n", paste(vapply(strsplit(x, "\n")[[1]], RCurl::base64Decode, 
        character(1), USE.NAMES = FALSE), collapse = " "))
    lines <- readLines(textConnection(tmp))
    lines <- vapply(lines, gsub, character(1), pattern = "\\s", replacement = "", 
        USE.NAMES = FALSE)
    sub("Version:\\s+|Version:|Version\\s:", "", lines[grep("Version", lines)])
}
check_cran <- function(pkg) {
    out <- tryCatch(readRDS("availpkgs.rds"), error = function(e) e)
    if (is(out, "simpleError")) {
        tmp <- data.frame(available.packages(), stringsAsFactors = FALSE)
        saveRDS(tmp, "availpkgs.rds")
    }
    ifelse(pkg %in% out$Package, "label label-success", "label label-default")
}
for_each_pkg <- function(repo) {
    iss_o <- gh_issues(repo = repo)
    iss_o <- ifemptyelse(iss_o, c("id", "number", "title", "created_at", "url"))
    iss_c <- gh_issues(repo = repo, query = list(state = "closed"))
    iss_c <- ifemptyelse(iss_c, c("id", "number", "title", "created_at", "url"))
    mile <- gh_milestones(repo = repo)
    mile <- ifemptyelse(mile, c("id", "number", "title", "open_issues", "closed_issues", 
        "created_at", "due_on", "url"))
    contribs <- gh_contributors(repo = repo)
    contribs <- ifemptyelse(contribs, c("login", "contributions", "avatar_url"))
    stars <- gh_stars(repo = repo)
    stars <- ifemptyelse(stars, c("login", "avatar_url"))
    forks <- gh_forks(repo = repo)
    forks <- ifemptyelse(forks, c("owner.login", "owner.avatar_url"))
    pr <- gh_pulls(repo = repo)
    pr <- ifemptyelse(pr, c("user.login", "user.avatar_url"))
    cm <- gh_commit_activity(repo = repo)
    cm_spark <- cm$total
    ver <- gh_check_file(repo = repo)
    oncran <- check_cran(repo)
    list(package = repo, ver = ver, iss_open = nrow(iss_o), iss_closed = nrow(iss_c), 
        milestones = nrow(mile), contribs = nrow(contribs), stars = nrow(stars), 
        forks = nrow(forks), prs = nrow(pr), sparkline = cm_spark, downloads = 0, 
        cran = oncran, notes = "-")
}
## Run this to generate data
out <- lapply(pkgs, for_each_pkg)
## Run this to generate the html, write the file, and open it in your default
## browser
html <- whisker.render(readLines("template.html"))
write(html, "index.html")
browseURL("index.html") 
