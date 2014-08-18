# Create this folder first
setwd("~/Github/CRAN_logs")
# Download all logs from start until now into this folder (actually a subfolder)
start <- as.Date('2012-10-01')
today <- as.Date(strsplit(as.character(lubridate::now()), " ")[[1]][1])
all_days <- seq(start, today, by = 'day')
year <- as.POSIXlt(all_days)$year + 1900
urls <- paste0('http://cran-logs.rstudio.com/', year, '/', all_days, '.csv.gz')
 
# only download the files you don't have:
missing_days <- setdiff(as.character(all_days), tools::file_path_sans_ext(dir("CRANlogs"), TRUE))
  
for (i in 1:length(missing_days)) {
  print(paste0(i, "/", length(missing_days)))
  download.file(urls[i], paste0('CRANlogs/', missing_days[i], '.csv.gz'))
}


file_list <- list.files("CRANlogs", full.names = TRUE)

logs <- list()
for (file in file_list) {
    print(paste("Reading", file, "..."))
    logs[[file]] <- read.table(file, header = TRUE, sep = ",", quote = "\"",
         dec = ".", fill = TRUE, comment.char = "", as.is = TRUE)
}

library(data.table)
downloads <- rbindlist(logs)
dl <- downloads[ , length(unique(ip_id)), by = 'package']
rm(downloads) # purge the large file

package <- c("alm", "AntWeb", "bmc", "bold", "clifro", "dependencies", "ecoengine", 
    "ecoretriever", "elastic", "elife", "floras", "fulltext", "geonames", "gistr", 
    "jekyll-knitr", "knitr-ruby", "mocker", "neotoma", "plotly", "rAltmetric", "rAvis", 
    "rbhl", "rbison", "rcrossref", "rdatacite", "rdryad", "rebird", "rentrez", "reol", 
    "reproducibility-guide", "rfigshare", "rfishbase", "rfisheries", "rflybase", 
    "rgauges", "rgbif", "rglobi", "rhindawi", "rImpactStory", "rinat", "RMendeley", 
    "rmetadata", "RNeXML", "rnoaa", "rnpn", "rotraits", "rplos", "rsnps", "rspringer", 
    "rvertnet", "rWBclimate", "solr", "spocc", "taxize", "togeojson", "treeBASE", 
    "ucipp", "testdat", "git2r", "EML")
package <- data.table(data.frame(package = sort(package)))

setkey(package, "package")
setkey(dl, "package")
short_list <- dl[package, ]
short_list[which(is.na(short_list$V1)), ]$V1 <- 0
cran_downloads <- as.list(short_list$V1)
names(cran_downloads) <- short_list$package
save(cran_downloads, file = "~/Github/ropensci/jumpin/cran_downloads.rda")




