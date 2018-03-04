# clean-up
rm(list = ls())

# load required libraries
library(gtrendsR)

# load data (stitch together multiple shorter time periods)
startDate <- "2017-01-01"
endDate <- "2018-02-21"
keyword <- "Cryptocurrency"
dd <- gtrends(keyword, time = paste(as.Date(startDate) + 0, as.Date(startDate) + 90))$interest_over_time[, 1:2]
dd$block <- 0
for (i in 1:4) {
  period <- paste(as.Date(startDate) + i*90, min(Sys.Date(), as.Date(startDate) + (i + 1)*90))
  cat("period =", period, "\n")
  dd <- rbind(dd, cbind(gtrends(keyword, time = period)$interest_over_time[, 1:2], block = i))
}
names(dd)[1:2] <- c("Date", "Popularity")
for (b in 1:4) {
  bc <- which(dd$block == b)
  bp <- which(dd$block == b - 1)
  dd[bc, 2] <- dd[bc, 2] * dd[bp[length(bp)], 2] / dd[bc[1], 2]
}
dd <- dd[-which(diff(dd$block) == 1), ]
dd$Popularity <- 100 * dd$Popularity / max(dd$Popularity)
dd$Date <- as.Date(dd$Date)
dd <- dd[dd$Popularity > 0, ]

dd <- dd[!(dd$Date < as.Date("2017-10-01")), ]


# posterior predictive check
load("fit.RData")
Y_meas <- dd$Popularity
plot(Time_pred, rep(NA, length(Time_pred)), ylim = c(0, max(Y_pred, Y_meas)),
     xlab = "Date", ylab = "Normalized popularity", 
     main = "Popularity of Cryptocurrency (social FOMO/FUD model)")
polygon(c(Time_pred, rev(Time_pred)), c(Y_pred[, 1], rev(Y_pred[, 3])),
        col = "lightgray", border = NA)
lines(Time_pred, Y_pred[, 2], lwd = 3)
ptcol <- c(rgb(1, 1, 1, 0.6), "red")[(dd$Date > as.Date(endDate)) + 1]
points(dd$Date, Y_meas, pch = 21, bg = ptcol, cex = 1.2, type = "b") 
lines(dd$Date, stats::filter(Y_meas, rep(1, 31)/31), col = "darkred", lwd = 2)
peaks <- Time_pred[c(which(Y_pred[, 1] == max(Y_pred[, 1])),
                     which(Y_pred[, 2] == max(Y_pred[, 2])),
                     which(Y_pred[, 3] == max(Y_pred[, 3])))]
legend("topleft", bty = "n", 
       legend = c("Fit data",
                  "Test data",
                  "31-day moving avg.",
                  "Curve of best fit",
                  "95% prediction interval"),
       lty = c(NA, NA, 1, 1, NA),
       lwd = c(NA, NA, 2, 3, NA),
       pch = c(21, 21, NA, NA, 15),
       col = c("black", "black", "darkred", "black", "gray"), 
       pt.cex = c(1.2, 1.2, NA, NA, 2),
       pt.bg = c("white", "red", NA, NA, NA))
abline(v = as.Date(endDate) + 0.5 + 7*0:10, col = "red", lwd = 0.5, lty = 3)
text(as.Date(endDate) + 0.5 + 7*0:9, 80, paste("WEEK", 1:10), srt = 90, cex = 0.8, col = "red", adj = c(0, 1))
