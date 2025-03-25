library("tidyverse")

load_data <- function(directory){
	files <- dir(directory, pattern="\\.csv",full.names=T)
	dataset <- bind_rows(map(files,read.csv))
	return(dataset)
}