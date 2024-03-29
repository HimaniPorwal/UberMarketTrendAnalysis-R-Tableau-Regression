#-------------------final code for data cleaning---------


#-------Loading through csv

install.packages("ggplot2")
library(ggplot2)

install.packages("zoo")
library(zoo)

install.packages("geosphere")
library(geosphere)

setwd("~/Desktop/R project/uber fare analysis/")

uberDataset<-read.csv("uber.csv")

summary(uberDataset)
head(uberDataset)

nrows<- nrow(uberDataset)
ncols<- ncol(uberDataset)

uberDataset$pickup_date<- as.Date(uberDataset$pickup_datetime)
uberDataset$pickup_time<- substring(uberDataset$pickup_datetime,12,19)
uberDataset$time_zone<- substring(uberDataset$pickup_datetime,21,23)

#uberDataset$pickup_region<- rep(NA, times= nrows)
#
#uberDataset$pickup_subregion<- rep(NA, times= nrows)
#
#uberDataset$dropoff_region<- rep(NA, times= nrows)
#
#uberDataset$dropoff_subregion<- rep(NA, times= nrows)





newDF<- uberDataset[uberDataset$dropoff_latitude != 0 
                    & uberDataset$pickup_latitude != 0 
                    & uberDataset$pickup_longitude !=0 
                    & uberDataset$dropoff_longitude != 0 
                    
                    & uberDataset$dropoff_longitude < 180    
                    & uberDataset$dropoff_longitude >  (-180)
                    & uberDataset$dropoff_latitude < 90      
                    & uberDataset$dropoff_latitude >  (-90)  
                    
                    & uberDataset$pickup_longitude < 180     
                    & uberDataset$pickup_longitude >  (-180) 
                    & uberDataset$pickup_latitude < 90       
                    & uberDataset$pickup_latitude >  (-90)   
                    
                    & uberDataset$passenger_count <= 7 
                    & uberDataset$passenger_count > 0
                    
                    & uberDataset$fare_amount > 0, ]


head(newDF)

summary(newDF)

-------------------


nrows<- nrow(newDF)

newDF$distance_meters<- rep(NA, times= nrows)





for (i in 1:195313){
  newDF$distance_meters[i] <- distGeo(c(newDF$pickup_longitude[i], newDF$pickup_latitude[i]), c(newDF$dropoff_longitude[i], newDF$dropoff_latitude[i]))
}


newDF$distance_meters


newDF$distance_miles <- newDF$distance_meters * 0.000621371

newDF$distance_miles



#-------------------
  
  
Uber1 <- newDF[ ,c(1,3,10,11,9,14)]


head(Uber1)

summary(Uber1)

colnames(Uber1)<- c('Key','fare_amount','pickup_date','pickup_time','passenger_count','distance_miles')


#-------------------

max(Uber1$distance_miles)



Uber1[Uber1$distance_miles == max(Uber1$distance_miles) ,]


Uber1[Uber1$distance_miles >1000 ,]

nrow(Uber1[(Uber1$distance_miles >50 & Uber1$fare_amount <50),])

#if fares are less than 50 and miles travelled is greater than 50 implies invalid data.

#-------------------

drop((Uber1$distance_miles >50 & Uber1$fare_amount <50))



# removed 50 rows whose distance was more than 50 miles and fares were not comparable

Uber1<- Uber1[(Uber1$distance_miles <50),]


nrow(Uber1) #195214

head(Uber1)

summary(Uber1)

#-------------------


nrow(Uber1[(Uber1$distance_miles == 0),])

# round trip or cancellation fees as distance is zero and fares are not zero.


#if fare amount is less (under 10 $) then it could be either cancellation fee or round trip.

# if fare amount is higher (more than 10) then it could be round trip.


Uber1<- Uber1[(Uber1$distance_miles != 0),]


nrow(Uber1) #193171

head(Uber1)

summary(Uber1)

#-------------------



round(Uber1$distance_miles,1)

#-------------------


#-------------------#-------------------#-------------------#-------------------

UberDatasetCleaned<- Uber1


head(UberDatasetCleaned)



Uber1$pickup_yearQuarter <-as.yearqtr(Uber1$pickup_date)


as.yearqtr(Uber1$pickup_date)

Uber1$pickup_month <-substring(Uber1$pickup_date,6,7 )
Uber1$pickup_year <- substring(Uber1$pickup_date,1,4 )
Uber1$pickup_yearQuarter <-as.yearqtr(Uber1$pickup_date)
Uber1$pickup_monthYear <-substring(Uber1$pickup_date,1,7 )

#-------------------Analysis-----#-------------------#-------------------


head(Uber1)

summary(Uber1)

nrow(Uber1)

#this shows that the fixed charge for booking a cab would be 11.20$ 
#and per passenger additional charge would be 0.09$
LM1<- lm(fare_amount~ passenger_count, data= Uber1)


summary(LM1)

sum(coef(LM1) * c(1,1))
sum(coef(LM1) * c(1,2))
sum(coef(LM1) * c(1,3))
sum(coef(LM1) * c(1,4))
sum(coef(LM1) * c(1,5))
sum(coef(LM1) * c(1,6))


# This histogram shows that passengers are preferring to travel individually than sharing their ride.

hist(Uber1$passenger_count)



#Trends of total revenue collected from fares from 2009 to 2015
Uber1$pickup_month <-substring(Uber1$pickup_date,6,7 )
Uber1$pickup_year <- substring(Uber1$pickup_date,1,4 )
Uber1$pickup_yearQuarter <-as.yearqtr(Uber1$pickup_date)
Uber1$pickup_monthYear <-substring(Uber1$pickup_date,1,7 )

DF1<- aggregate( fare_amount~ pickup_yearQuarter , FUN=sum , data= Uber1)


ggplot( data=DF1, aes( x=pickup_yearQuarter, y=fare_amount ) )+
  geom_point()+
  geom_smooth(method=lm, se=FALSE)

install.packages("zoo")
library(zoo)

as.yearqtr(Uber1$pickup_date)

#Trends of annual count of passengers who took the rides from 2009 to 2015

DF2<- aggregate( passenger_count~ pickup_yearQuarter , FUN=sum , data= Uber1)

ggplot( data=DF2, aes( x=pickup_yearQuarter, y=passenger_count ) )+
  geom_point()+
  geom_smooth(method=lm, se=FALSE)





sum(Uber1$fare_amount)



#-------------------#---------------Export to CSV in R----------------------
 


# Export dataframe to CSV
write.csv(Uber1, "output.csv", row.names = FALSE)

write.csv(Uber1)


#-------------------#-#-------------------#-#-------------------#-

install.packages("openxlsx")
library(openxlsx)

# Create a sample dataframe
data <- data.frame(
  ID = c(1, 2, 3),
  Name = c("Alice", "Bob", "Charlie")
)

# Export dataframe to Excel (XLSX)
write.xlsx(data, "output.xlsx")

#-------------------#-#-------------------#-#-------------------#-




hist(Uber1$fare_amount)



summary(lm(fare_amount~ passenger_count, data= Uber1))

summary(lm(fare_amount~ distance_miles, data= Uber1))

summary(lm(fare_amount~ pickup_time, data= Uber1))

summary(lm(fare_amount~ pickup_date, data= Uber1))


ggplot( data=Uber1, aes( x=pickup_date, y=fare_amount ) )+
  geom_point()+
  geom_smooth(method=lm, se=FALSE)

ggplot( data=Uber1, aes( x=distance_miles, y=fare_amount ) )+
  geom_point()+
  geom_smooth(method=lm, se=FALSE)

ggplot( data=Uber1, aes( x=passenger_count, y=fare_amount ) )+
  geom_point()+
  geom_smooth(method=lm, se=FALSE)


Uber1[Uber1$Key== 51151143,]

----------------------------
  
  
 lm(fare_amount ~ passenger_count , data= Uber1)

summary(uber)

?summary

sum(coef(uber)* c(1,1))



#--------------------------
  
  
  aggregate( Key~ passenger_count , FUN= , data= Uber1)
















