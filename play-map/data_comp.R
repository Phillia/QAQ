#topic: uninusred
#kff
#total: https://www.kff.org/other/state-indicator/total-population/?currentTimeframe=0&sortModel=%7B%22colId%22:%22Location%22,%22sort%22:%22asc%22%7D


#how many years
get_yr <- function(dt,key) {
        nam <- names(dt)
        substr(nam[grep(key,nam)],2,5)
}


uninsured.tot.pct <- read.csv("./data/uninsured_total_pct.csv",skip=2) %>% filter(complete.cases(.))
uninsured.tot.pct <- uninsured.tot.pct %>% select(grep("Location|Uninsured",names(.))) %>% set_names("statename",paste0("uninsured_pct_",get_yr(uninsured.tot.pct,"Uninsured")))


