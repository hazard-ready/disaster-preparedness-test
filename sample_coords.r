#!/usr/bin/env Rscript

library('rgdal')
library('plyr')

covered_area <- readOGR(dirname(sys.frame(1)$ofile), "boundary")
batch_size <- 2500
total <- 10000000

random_points <- function(n) {
	tryCatch({
		coordinates(spsample(covered_area, n, "random"))
	},
	error = function(e) {
		message("Intercepted the following error message:")
		message(e)
		message("Retrying.  If these messages keep coming in quick succession, then abort the script and debug.")
		random_points(n)
	})
}

message(paste("Generating", total, "random points."))

# Generate samples and merge into a single dataframe
for (n in 1:(total/batch_size)) {
	rez <- t(apply(count(array(1:batch_size, c(batch_size, 1))), 1, function(x) random_points(1)))
	rownames(rez) <- NULL
	write.table(rez, paste(dirname(sys.frame(1)$ofile), "coords.csv", sep="/"), col.names= FALSE, row.names= FALSE, append = TRUE, sep = ",")
	message(paste("Generated", n*batch_size, "points so far."))
}
