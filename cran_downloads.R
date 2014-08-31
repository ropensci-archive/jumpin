load('local_data/settings.rda')
library(data.table)
start <- settings[[1]]
rebuild_index <- settings[[2]]
# Set rebuild index to TRUE if you want to start again from scratch
# rebuild_index <- TRUE


# Download all logs from start until now into this folder (actually a subfolder)
if(rebuild_index) {
  start <- as.Date('2012-10-01')
} else {
  start <- start
}
today <- as.Date(strsplit(as.character(lubridate::now()), " ")[[1]][1])
all_days <- seq(start, today, by = 'day')
year <- as.POSIXlt(all_days)$year + 1900
urls <- paste0('http://cran-logs.rstudio.com/', year, '/', all_days, '.csv.gz')
 
# only download the files you don't have:
missing_days <- setdiff(as.character(all_days), tools::file_path_sans_ext(dir("CRANlogs"), TRUE))
 
if(length(missing_days) > 0) {
for (i in 1:length(missing_days)) {
  print(paste0(i, "/", length(missing_days)))
  download.file(urls[i], paste0('CRANlogs/', missing_days[i], '.csv.gz'))
}
}

file_list <- list.files("CRANlogs", full.names = TRUE)

if(rebuild_index) {
logs <- list()
for (file in file_list) {
    print(paste("Reading", file, "..."))
    logs[[file]] <- read.table(file, header = TRUE, sep = ",", quote = "\"",
         dec = ".", fill = TRUE, comment.char = "", as.is = TRUE)
}
downloads <- rbindlist(logs)
dl <- downloads[ , length(unique(ip_id)), by = 'package']
save(dl, file = 'local_data/dl.rda')
rm(downloads)
# If not rebuilding, just load existing index 
# and append data
} else { 
load('local_data/dl.rda')  
if(length(missing_days) > 0) {
    message(sprintf("Building %s new logs", length(missing_days)))
    updated_logs <- list() 
    for(i in missing_days) {
      file <- paste0("CRANlogs/", missing_days[i], ".csv.gz")
      updated_logs[[i]] <- read.table(file, header = TRUE, sep = ",", quote = "\"",
             dec = ".", fill = TRUE, comment.char = "", as.is = TRUE)
    }
    updated_downloads <- rbindlist(updated_logs)
    udl <- updated_downloads[ , length(unique(ip_id)), by = 'package']
    rm(updated_downloads) # purge the large object
    dl <- rbind(dl, udl)
    # This will update the numbers
    dl <- dl[, sum(V1), by = "package"]
  }
}

# Now we reduce the giant CRAN log to just our packages, and just to unique IP downloads


package_dt <- data.table(data.frame(package = sort(package)))

setkey(package_dt, "package")
setkey(dl, "package")
short_list <- dl[package_dt, ]
short_list[which(is.na(short_list$V1)), ]$V1 <- 0
save(short_list, file = "local_data/short_list.rda")
cran_downloads <- as.list(short_list$V1)
names(cran_downloads) <- short_list$package
save(cran_downloads, file = "local_data/cran_downloads.rda")
start <- today
rebuild_index <- FALSE
settings <- list(start = start, rebuild_index = rebuild_index)
save(settings, file = "local_data/settings.rda")


