# clean-up
rm(list = ls())

# load required libraries
library(gtrendsR)
library(anytime)
library(ggplot2)
library(ggthemes)

# load market cap data from 2017/01/01 until 2018/03/04
mc <- read.csv("data/market_cap.csv")
mc$timestamp <- anydate(mc$timestamp/1000)
mc$market_cap <- mc$market_cap / 1000

# obtain Google Trends data (stitch together multiple shorter time periods)
startDate <- "2017-01-07"
endDate <- "2018-03-04"
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

# match lengths of data
mc <- mc[1:nrow(dd), ]

# stitch together
dd$market_cap <- mc$market_cap
dd$block <- NULL
dd <- dd[1:424, ]

# plot cross-correlation function
res <- ccf(log(dd$Popularity), log(dd$market_cap), lag.max = 128, plot = F)
res <- data.frame(lag = res$lag[, , 1], ccf = res$acf[, , 1])
ggplot(res, aes(x = lag, y = ccf)) + 
  geom_line(lwd = 1.5) + 
  geom_area(alpha = 0.2) + 
  ggtitle("Cross-correlation function for 'Cryptocurrency' Google Trends and Total Market Cap") +
   theme(axis.text = element_text(size = 12), axis.title = element_text(size = 14, face="bold"))


