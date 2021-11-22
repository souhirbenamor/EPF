###BE PRICE CODE ts and periodogram#####
library(tidyverse)
library(forecast)
library(stringr)
library("readxl")
#plot the time series, ACF and PACF
BE =read_excel( "/Users/vaughan/Desktop/BE_logreturn.xlsx")
BE=t(BE)
# we'll just set the correct start year, for display purposes.
BE<-ts(as.numeric(BE),start=622,frequency=1)
 ggtsdisplay(BE,lag.max=350, main='BE time series.', theme=theme_bw())
 #plot the periodogram (source: https://rstudio-pubs-static.s3.amazonaws.com/9428_1197bd003ebd43c49b429f22ea4f36e5.html)
 raw.spec <- spec.pgram(BE, taper = 0)
 plot(raw.spec)
 plot(raw.spec, log = "no")
 
 #ARIMA and GARMA 
 library(garma)
 library(ggplot2)
 library(data.table)
 library(igraph)
 require(timeDate)
 library(stringr)
 library(graphics)
 library(stringr)
 library("readxl")
 library(tidyverse)
 library(forecast)
 # Next we subset the data to ensure we are using the years used in the literature.
 BEts <- ts(BE[20:34944],start=20,end=34944)
 # Now as in Gray et al 1989 we fit a GARMA(1,0) model:
 BEts_arima_mdl <- arima(BEts, order=c(9,0,0),method='CSS')
 summary(BEts_arima_mdl)
 #####
 
 #BEts_garma_mdl <- garma(BEts, order=c(1,0,0),k=3,method='CSS')
 #summary(BEts_garma_mdl)
 ####
 library(yardstick)
 
 (BEts_garma_mdl <- garma(BEts, order = c(9, 1, 0), k = 3))
 compare_df <- data.frame(yr=34945:52416, Actuals=as.numeric(BE[34945:52416]), ARIMA=forecast(BEts_arima_mdl,h=17472)$mean, GARMA=forecast(BEts_garma_mdl,h=17472)$mean)
 cat(sprintf('\n\nEvaluating Test set data from 2015 to 2016.\n\nARIMA RMSE: %.2f\nGARMA RMSE: %.2f\n', yardstick::rmse(compare_df,Actuals,ARIMA)$.estimate, yardstick::rmse(compare_df,Actuals,GARMA)$.estimate))
 
 arima_df <- data.frame(yr=34945:52416, BEts=forecast(BEts_arima_mdl,h=17472)$mean,grp='AR(11) forecasts')
 garma_df <- data.frame(yr=34945:52416, BEts=forecast(BEts_garma_mdl,h=17472)$mean,grp='GARMA(1),k=3 forecasts')
 actuals_df <- data.frame(yr=20:52416,BEts=as.numeric(BE[20:52416]),grp='Actuals')
 df <- rbind(actuals_df,garma_df,arima_df) 
 
 ggplot(df,aes(x=yr,y=BEts,color=grp)) + geom_line() 
 scale_color_manual(name='',values=c('Actuals'='darkgray','AR(11) forecasts'='darkgreen','GARMA(1),k=3 forecasts'='blue')) +
   xlab('') + ylab('BE Counts') +
   geom_vline(xintercept=34944,color='red',linetype='dashed',size=0.3) +
   theme_bw() +
   ggtitle('BE Forecasts: Comparing ARIMA(9,0,0) and GARMA(9,0),k=3')
 #save the output
 write.csv(garma_df, paste0("/Users/vaughan/Desktop/garma3_out.csv"), row.names = FALSE, quote = FALSE)
 write.csv(arima_df, paste0("/Users/vaughan/Desktop/arima_out.csv"), row.names = FALSE, quote = FALSE)
 
 
