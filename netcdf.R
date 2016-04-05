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
points(rep(lon,length(lat)),rep(lat,each=length(lon)),pch=".")

## Without sp package
plot(rep(lon,length(lat)),rep(lat,each=length(lon)),type="p",pch=".", asp=TRUE)
plot(hun, add=TRUE)

## Draw a point
points(16.58333,47.58333,col="red")
## The same with index
points(lon[35],lat[31],col="red") ## below Hidegvíz

######################################################################
## Write average temp for Hungary.
######################################################################
## Create new ncdf some dimensions above
## define a variable for
## For past
nc.filename <- "fresee2.1_tmean.nc"
nc.units <- "days since 1951-01-01"

## For REMO
nc.filename <- "fresee2.1_REMO_tmean.nc"
nc.units <- "days since 2015-01-01"
## Open existing netcdf files
ncmin <- nc_open(ncnam[3])
ncmax <- nc_open(ncnam[2])
nctimlength <- length(ncvar_get(ncmin,"time"))
tim <- ncdim_def( "Time", units = nc.units, 1:nctimlength, unlim=TRUE)
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

nc.open(nc.filename)
ncvar_get(remo,"Lon")
ncvar_get(remo,"Lat")
