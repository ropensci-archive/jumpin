# Writes out the entire index.html by rebuilding CRAN index and querying GitHub for latest stats
setwd("~/Github/ropensci/jumpin")
load('local_data/settings.rda')

package <- c("alm", "AntWeb", "bmc", "bold", "clifro", "dependencies", "ecoengine", 
    "ecoretriever", "elastic", "elife", "floras", "fulltext", "geonames", "gistr", 
    "jekyll-knitr", "mocker", "neotoma", "plotly", "rAltmetric", "rAvis", 
    "rbhl", "rbison", "rcrossref", "rdatacite", "rdryad", "rebird", "rentrez", "reol", 
    "reproducibility-guide", "rfigshare", "rfishbase", "rfisheries", "rflybase", 
    "rgauges", "rgbif", "rglobi", "rhindawi", "rImpactStory", "rinat", "RMendeley", 
    "rmetadata", "RNeXML", "rnoaa", "rnpn", "traits", "rplos", "rsnps", "rspringer", 
    "rvertnet", "rWBclimate", "solr", "spocc", "taxize", "togeojson", "treeBASE", 
    "ucipp", "testdat", "git2r", "EML")

# IF YOU UPDATE THE LIST ABOVE, uncomment the line below
# rebuild_index = TRUE


# Build CRAN index

message("Updating CRAN logs. This will take a while if this is the first run")
source('cran_downloads.R')

# Build the GitHub stats

source('jumpin2.R')

