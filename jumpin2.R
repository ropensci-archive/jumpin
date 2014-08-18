library("devtools")
library("httr")
library("whisker")
library("yaml")
library("lubridate")
# This file has the CRAN downloads for the packages below.
# To update, run cran_downloads.R (this will take a while the first time)
load('cran_downloads.rda')
## List of rOpenSci packages
pkgs <- c("alm", "AntWeb", "bmc", "bold", "clifro", "dependencies", "ecoengine", 
    "ecoretriever", "elastic", "elife", "floras", "fulltext", "geonames", "gistr", 
    "jekyll-knitr", "knitr-ruby", "mocker", "neotoma", "plotly", "rAltmetric", "rAvis", 
    "rbhl", "rbison", "rcrossref", "rdatacite", "rdryad", "rebird", "rentrez", "reol", 
    "reproducibility-guide", "rfigshare", "rfishbase", "rfisheries", "rflybase", 
    "rgauges", "rgbif", "rglobi", "rhindawi", "rImpactStory", "rinat", "RMendeley", 
    "rmetadata", "RNeXML", "rnoaa", "rnpn", "rotraits", "rplos", "rsnps", "rspringer", 
    "rvertnet", "rWBclimate", "solr", "spocc", "taxize", "togeojson", "treeBASE", 
    "ucipp", "testdat", "git2r", "EML")
pkgs <- sort(pkgs)



# setwd("~/Github/ropensci/jumpin")
# Create a new app, set Authorization callback URL = http://localhost:1410
# Then copy the keys into your .rprofile with the names below
myapp <- oauth_app(getOption("gh_appname"), getOption("gh_id"), getOption("gh_secret"))
token <- github_token <- oauth2.0_token(oauth_endpoints("github"), myapp) 

github_stats <- function(repo) {

	repo_url <- paste0("https://api.github.com/repos/ropensci/", repo)
	data <- GET(repo_url, config = c(token = token))
	results <- content(data, "parsed")
	dl <- content(GET(results$downloads_url, config = c(token = token)), "parsed")
	downloads <- ifelse(length(dl) == 0, 0, length(dl))
	collab <- content(GET(results$contributors_url, config = c(token = token)), "parsed")
	collaborators <- length(collab)
	cnames <- lapply(collab, "[", "login")
	cnames <- sapply(cnames, unname)
	collaborator_names <- as.character(paste(cnames, collapse = ", "))
	prs <- length(content(GET(paste0(repo_url, "/pulls"), config = c(token = token)), "parsed"))
	# Didn't add closed issues or version number since neither make sense as a reason for someone to jump in
	commits_raw <- GET(paste0(repo_url, "/stats/commit_activity"), config = c(token = token))
	commits <- jsonlite::fromJSON(content(commits_raw, "text"), flatten = TRUE)$total

	date <- gsub("T", " ",  results$pushed_at)
	date <- gsub("Z", " UTC", date)

	cran_return <- GET(paste0("http://cran.r-project.org/web/packages/", repo, "/index.html"))$status
	cran <- ifelse(cran_return == 200, "label label-success", "label label-default")
	milestones <- length(content(GET(paste0(repo_url, "/milestones"), config = c(token = token)), "parsed"))
	list(package = results$name, 
		desc = results$description, 
		updated = date, 
		forks = results$forks,
		stars = results$stargazers_count,
		downloads = downloads,
		cran_downloads = cran_downloads[[repo]], 
		pull_requests = prs,
		cran = cran,
		collaborators = collaborators,
		collaborator_names = collaborator_names,
		milestones = milestones,
		watchers = results$subscribers_count,
		open_issues = results$open_issues_count,
		sparkline = commits)
}

message("Now querying results \n")
results <- lapply(pkgs, github_stats)
last_generated <- now("UTC")
out <- results
message("writing out html \n")
html <- whisker.render(readLines("template2.html"))
write(html, "index.html")
browseURL("index.html") 

