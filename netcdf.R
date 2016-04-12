## nc files in the current directory
dir(patt="nc")

## Load library
library(ncdf4)

######################################################################
### Plot with boundary
######################################################################
## With sp package
library(sp)
hun <- readRDS("HUN_adm0.rds")
plot(hun, xlim=c(10.92,28.08), ylim=c(42.58,51.08))
## Only Hungary
plot(hun, xlim=c(16,22.95), ylim=c(45.7,48.6))
nc.filename <- "fresee2.1_REMO_tmean.nc"
remo <- nc_open(nc.filename)
lon <- ncvar_get(remo,"Lon")
lat <- ncvar_get(remo,"Lat")
points(rep(lon,length(lat)),rep(lat,each=length(lon)),pch=".")

## Without projection
plot(rep(lon,length(lat)),rep(lat,each=length(lon)),type="p",pch=".", asp=TRUE)
plot(hun, add=TRUE)

## Draw a point
points(16.58333,47.58333,col="red")
## The same with index
points(lon[4],lat[12],col="blue") ## below Hidegvíz

## Marchfeld: Draw a point
points(16.34,48.2,col="green")
## The same with index
points(lon[3],lat[16],col="purple") 

march.remo <- ncvar_get(remo,"Mean temperature", c(3,16,1),c(1,1,31390))


######################################################################
## Write average temp for Hungary.
######################################################################
## Create new ncdf some dimensions above
## define a variable for
## For past
nc.filename <- "fresee2.1_tmean.nc"
nc.units <- "days since 1951-01-01"

## For REMO
ncnam <- dir(patt = "REMO")
nc.filename <- "fresee2.1_REMO_tmean.nc"


## For HIRHAM5
ncnam <- dir(patt="RCA")
nc.filename <- "fresee2.1_SMHIRCA_tmean.nc"

nc.units <- "days since 2015-01-01"
## Open existing netcdf files
ncmin <- nc_open(ncnam[3])
ncmax <- nc_open(ncnam[2])
nctimlength <- length(ncvar_get(ncmin,"time"))
## define the dimensions
tim <- ncdim_def( "Time", units = nc.units, 1:nctimlength, unlim=TRUE)
mo.x <- ncdim_def( "Lon", "degreesE", seq(15.75+2/6,22.75+1/6,1/6))
mo.y <- ncdim_def( "Lat", "degreesN", seq(45.75,48.25+2/6,1/6))
foreseemean <- ncvar_def("Mean temperature", "degree Celsius",  list(mo.x,mo.y,tim), NULL, prec = "float")
nc.foreseemean <- nc_create(nc.filename, foreseemean)
for(ttlon in 32:73) { #
    for(ttlat in 20:37) {
        ## Get data from netcdf files
        tmpmin <- ncvar_get(ncmin,"tmin",c(ttlon,ttlat,1),c(1,1,nctimlength))
        tmpmax <- ncvar_get(ncmax,"tmax",c(ttlon,ttlat,1),c(1,1,nctimlength))
        ## Calculate average
        tmpmean <- (tmpmax+tmpmin)/2
        ncvar_put(nc.foreseemean, foreseemean, tmpmean, start= c(ttlon - 31, ttlat - 19,1), count=c(1,1,length(tmpmean)))
    }
}
## Close netcdf files
nc_close(ncmin)
nc_close(ncmax)
nc_close(nc.foreseemean)

#########################################################
#########################################################
## Cut out precipitation past

ncnam <- dir(patt= "1951")
nc.filename <- "fresee2.1_prec.nc"

nc.units <- "days since 1951-01-01"
## Open existing netcdf files
ncprec <- nc_open(ncnam[1])
nctimlength <- length(ncvar_get(ncprec,"time"))
## define the dimensions
tim <- ncdim_def( "Time", units = nc.units, 1:nctimlength, unlim=TRUE)
mo.x <- ncdim_def( "Lon", "degreesE", seq(15.75+2/6,22.75+1/6,1/6))
mo.y <- ncdim_def( "Lat", "degreesN", seq(45.75,48.25+2/6,1/6))
foreseeprec <- ncvar_def("Precipitation", "mm",  list(mo.x,mo.y,tim), NULL, prec = "float")
nc.foreseeprec <- nc_create(nc.filename, foreseeprec)
for(ttlon in 32:73) { #
    for(ttlat in 20:37) {
        ## Get data from netcdf files
        tmpprec <- ncvar_get(ncprec,"pr",c(ttlon,ttlat,1),c(1,1,nctimlength))
        ncvar_put(nc.foreseeprec, foreseeprec, tmpprec, start= c(ttlon - 31, ttlat - 19,1), count=c(1,1,length(tmpprec)))
    }
}
## Close netcdf files
nc_close(ncprec)
nc_close(nc.foreseeprec)

#################################################################################
## Cut out precipitation

ncnam <- dir(patt= "HIRHAM5")
nc.filename <- "fresee2.1_DMIHIRHAM5_prec.nc"

nc.units <- "days since 2015-01-01"
## Open existing netcdf files
ncprec <- nc_open(ncnam[1])
nctimlength <- length(ncvar_get(ncprec,"time"))
## define the dimensions
tim <- ncdim_def( "Time", units = nc.units, 1:nctimlength, unlim=TRUE)
mo.x <- ncdim_def( "Lon", "degreesE", seq(15.75+2/6,22.75+1/6,1/6))
mo.y <- ncdim_def( "Lat", "degreesN", seq(45.75,48.25+2/6,1/6))
foreseeprec <- ncvar_def("Precipitation", "mm",  list(mo.x,mo.y,tim), NULL, prec = "float")
nc.foreseeprec <- nc_create(nc.filename, foreseeprec)
for(ttlon in 32:73) { #
    for(ttlat in 20:37) {
        ## Get data from netcdf files
        tmpprec <- ncvar_get(ncprec,"pr",c(ttlon,ttlat,1),c(1,1,nctimlength))
        ncvar_put(nc.foreseeprec, foreseeprec, tmpprec, start= c(ttlon - 31, ttlat - 19,1), count=c(1,1,length(tmpprec)))
    }
}
## Close netcdf files
nc_close(ncprec)
nc_close(nc.foreseeprec)

#################################################################################

## Date for precipitation: REMO
ncnam <- dir(patt= "REMO")
ncprec.ori <- nc_open(ncnam[1])
## Substract date from original file
date.d <- as.Date(paste(ncvar_get(ncprec,"year"),ncvar_get(ncprec,"month"),ncvar_get(ncprec,"day"),sep="-"))
nc_close(ncprec.ori)

## Load data for a Marchfeld pixel
ncprec <- nc_open("fresee2.1_REMO_prec.nc")
march.prec.remo <- ncvar_get(ncprec,"Precipitation", c(3,16,1),c(1,1,31390))
nc_close(ncprec)

prec.remo.xts <- xts(march.prec.remo, date.d)
plot(prec.remo.xts, xaxs="i")

###################################################################################

## Date for precipitation: KNMIRACMO2
ncnam <- dir(patt= "RACMO2")
ncprec.ori <- nc_open(ncnam[1])
## Substract date from original file
date.d <- as.Date(paste(ncvar_get(ncprec,"year"),ncvar_get(ncprec,"month"),ncvar_get(ncprec,"day"),sep="-"))
nc_close(ncprec.ori)

## Load data for a Marchfeld pixel
ncprec <- nc_open("fresee2.1_KNMIRACMO2_prec.nc")
march.prec.knmi <- ncvar_get(ncprec,"Precipitation", c(3,16,1),c(1,1,31390))
nc_close(ncprec)

prec.knmi.xts <- xts(march.prec.knmi, date.d)
plot(prec.knmi.xts, xaxs="i")

####################################################################################

## Date for precipitation: DMI
ncnam <- dir(patt= "HIRHAM")
ncprec.ori <- nc_open(ncnam[1])
## Substract date from original file
date.d <- as.Date(paste(ncvar_get(ncprec,"year"),ncvar_get(ncprec,"month"),ncvar_get(ncprec,"day"),sep="-"))
nc_close(ncprec.ori)

## Load data for a Marchfeld pixel
ncprec <- nc_open("fresee2.1_DMIHIRHAM5_prec.nc")
march.prec.dmi <- ncvar_get(ncprec,"Precipitation", c(3,16,1),c(1,1,31390))
nc_close(ncprec)

prec.dm.xts <- xts(march.prec.dmi, date.d)
plot(prec.dm.xts, xaxs="i")

####################################################################################

## Date for precipitation: SM
ncnam <- dir(patt= "RCA")
ncprec.ori <- nc_open(ncnam[1])
## Substract date from original file
date.d <- as.Date(paste(ncvar_get(ncprec,"year"),ncvar_get(ncprec,"month"),ncvar_get(ncprec,"day"),sep="-"))
nc_close(ncprec.ori)

## Load data for a Marchfeld pixel
ncprec <- nc_open("fresee2.1_SMHIRCA_prec.nc")
march.prec.sm <- ncvar_get(ncprec,"Precipitation", c(3,16,1),c(1,1,31390))
nc_close(ncprec)

prec.sm.xts <- xts(march.prec.sm, date.d)
plot(prec.sm.xts, xaxs="i")

###################################################################################
## T-E-M-P-E-R-A-T-U-R-E
## T-E-M-P-E-R-A-T-U-R-E
###################################################################################

####################################################################################

## Date for Temp: SM
ncnam <- dir(patt= "RCA")
ncprec.ori <- nc_open(ncnam[5])
## Substract date from original file
date.d <- as.Date(paste(ncvar_get(ncprec,"year"),ncvar_get(ncprec,"month"),ncvar_get(ncprec,"day"),sep="-"))
nc_close(ncprec.ori)

## Load data for a Marchfeld pixel
nctemp <- nc_open("fresee2.1_SMHIRCA_tmean.nc")
march.temp.sm <- ncvar_get(nctemp,"Mean temperature", c(3,16,1),c(1,1,31390))
nc_close(nctemp)

temp.sm.xts <- xts(march.temp.sm, date.d)
plot(temp.sm.xts, xaxs="i")

####################################################################################

## Date for Temp: DM
ncnam <- dir(patt= "HIRHAM5")
ncprec.ori <- nc_open(ncnam[5])
## Substract date from original file
date.d <- as.Date(paste(ncvar_get(ncprec,"year"),ncvar_get(ncprec,"month"),ncvar_get(ncprec,"day"),sep="-"))
nc_close(ncprec.ori)

## Load data for a Marchfeld pixel
nctemp <- nc_open("fresee2.1_DMIHIRHAM5_tmean.nc")
march.temp.dm <- ncvar_get(nctemp,"Mean temperature", c(3,16,1),c(1,1,31390))
nc_close(nctemp)

temp.dm.xts <- xts(march.temp.dm, date.d)
plot(temp.dm.xts, xaxs="i")

####################################################################################

## Date for Temp: KNMI
ncnam <- dir(patt= "RACMO2")
ncprec.ori <- nc_open(ncnam[5])
## Substract date from original file
date.d <- as.Date(paste(ncvar_get(ncprec,"year"),ncvar_get(ncprec,"month"),ncvar_get(ncprec,"day"),sep="-"))
nc_close(ncprec.ori)

## Load data for a Marchfeld pixel
nctemp <- nc_open("fresee2.1_KNMIRACMO2_tmean.nc")
march.temp.knmi <- ncvar_get(nctemp,"Mean temperature", c(3,16,1),c(1,1,31390))
nc_close(nctemp)

temp.knmi.xts <- xts(march.temp.knmi, date.d)
plot(temp.knmi.xts, xaxs="i")

####################################################################################

## Date for Temp: REMO
ncnam <- dir(patt= "REMO")
ncprec.ori <- nc_open(ncnam[5])
## Substract date from original file
date.d <- as.Date(paste(ncvar_get(ncprec,"year"),ncvar_get(ncprec,"month"),ncvar_get(ncprec,"day"),sep="-"))
nc_close(ncprec.ori)

## Load data for a Marchfeld pixel
nctemp <- nc_open("fresee2.1_REMO_tmean.nc")
march.temp.remo <- ncvar_get(nctemp,"Mean temperature", c(3,16,1),c(1,1,31390))
nc_close(nctemp)

temp.remo.xts <- xts(march.temp.remo, date.d)
plot(temp.remo.xts, xaxs="i")

remo.echam = merge.xts(t=temp.remo.xts,p=prec.remo.xts)
knmi.racmo2 = merge.xts(t=temp.knmi.xts,p=prec.knmi.xts)
dmi.echam = merge.xts(t=temp.dm.xts,p=prec.dm.xts)
smhirca.bcm = merge.xts(t=temp.sm.xts,p=prec.sm.xts)

## Write data
write.zoo(remo.echam,"remotest.csv",sep=";",dec=",")
