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
ncnam <- dir("REMO")
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
