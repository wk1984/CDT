
	## data time step
	freqData <- 'dekadal'

	## year range
	year1 <- 1983
	year2 <- 2010

	## Training data file (CDT data)
	stnFile <- '/Users/rijaf/Desktop/ECHANGE/CDT_WD/new_method_merging/data/ETH/Data/RR_DEK_83to14_Train.txt'

	## Validation data file (CDT data)
	stnValidFile <- '/Users/rijaf/Desktop/ECHANGE/CDT_WD/new_method_merging/data/ETH/Data/RR_DEK_83to14_Valid.txt'

	## Station missing values code
	miss.val <- -99

	## Bias corrected data directory
	adjDIR <- '/Users/rijaf/Desktop/vETH_ENACTS/ADJ'
	## corrected data filename format
	adjFFormat <- 'rr_adj_%s%s%s.txt'

	## RFE sample file
	rfeFile <- '/Users/rijaf/Desktop/ECHANGE/CDT_WD/new_method_merging/data/ETH/TAMSAT_dek/rfe_1983012.nc'

	## elevation data file
	demFile <- '/Users/rijaf/Desktop/ECHANGE/CDT_WD/new_method_merging/data/ETH/dem/DEM_1_Arc-Minute.nc'

	## Spatio-Temporal LM Coef Output directory
	SPLM.coefDIR <- '/Users/rijaf/Desktop/vETH_ENACTS/LMCoef'

	#####################################################################################

	rad.lon <- 10
	rad.lat <- 10
	rad.elv <- 4
	maxdist <- 0.6

	months <- 1:12

	GeneralParameters$Interpolation.pars$nmin <- 3
	GeneralParameters$Interpolation.pars$nmax <- 10

	GeneralParameters$LM.Params$min.length <- 15
	GeneralParameters$LM.Params$min.stn <- 10

	#########################################################
	GeneralParameters$period <- freqData
	GeneralParameters$LM.Months <- months
	GeneralParameters$LM.Date.Range$start.year <- year1
	GeneralParameters$LM.Date.Range$end.year <- year2
	GeneralParameters$Interpolation.pars$vgm.model <- list(c("Sph", "Exp", "Gau"))

	#####################################################################################
	
	#### COMBINAISON

	LMcomb <- LMCoef.combination()

	##same aux.var, "noD", "D", "SA", "DSA"
	ix1 <- (LMcomb$bias.auxvar == LMcomb$LMcoef.auxvar) & LMcomb$bias.auxvar%in%c("noD", "D", "SA", "DSA", "LoLa", "DLoLa", "DSALoLa")

	## Bias and LMCoef same aux.var and interpolation
	ix2 <- LMcomb$bias.interp == LMcomb$LMcoef.interp

	ix <- ix1 & ix2
	LMcomb <- LMcomb[ix, ]

	#####################################################################################
	if(doparallel){
		klust <- makeCluster(nb_cores)
		registerDoParallel(klust)
		`%parLoop%` <- `%dopar%`
		closeklust <- TRUE
	}else{
		`%parLoop%` <- `%do%`
		closeklust <- FALSE
	}
	packages <- c('sp', 'gstat', 'automap', 'rgdal')
	toExports <- c('GeneralParameters', 'fitLM.month.RR', 'fitLM.fun.RR')

	#####################################################################################
	## STN data
	stnData <- read.table(stnFile, stringsAsFactors = FALSE, na.strings = str_trim(miss.val))
	stnData <- getCDTdataAndDisplayMsg(stnData, freqData)

	## validation coordinates
	coordsValid <- read.table(stnValidFile, stringsAsFactors = FALSE, na.strings = str_trim(miss.val))
	coordsValid <- getCDTdataAndDisplayMsg(coordsValid, freqData)
	coordsValid <- coordsValid[c('lon', 'lat')]

	## DEM data
	nc <- nc_open(demFile)
	demData <- list(lon = nc$dim[[1]]$vals, lat = nc$dim[[2]]$vals, demMat = ncvar_get(nc, nc$var[[1]]$name))
	nc_close(nc)

	## RFE info file
	nc <- nc_open(rfeFile)
	grd.lon <- nc$dim[[1]]$vals
	grd.lat <- nc$dim[[2]]$vals
	nc_close(nc)

	#########
	xy.grid <- list(lon = grd.lon, lat = grd.lat)
	grdSp <- defSpatialPixels(xy.grid)
	nlon0 <- length(grd.lon)
	nlat0 <- length(grd.lat)

	#### interpolation coordinates
	ijInt <- grid2pointINDEX(list(lon = coordsValid$lon, lat = coordsValid$lat), xy.grid)
	ijTrain <- grid2pointINDEX(list(lon =stnData$lon, lat = stnData$lat), xy.grid)

	##### ADJ data
	start.date <- as.Date(paste(year1, '0101', sep = ''), format = '%Y%m%d')
	end.date <- as.Date(paste(year2, '1231', sep = ''), format = '%Y%m%d')
	errmsg <- "Adjusted data not found"

	#####################################################################################

	demData$demMat[demData$demMat < 0] <- 0
	demSp <- defSpatialPixels(list(lon = demData$lon, lat = demData$lat))
	is.regridDEM <- is.diffSpatialPixelsObj(grdSp, demSp, tol = 1e-07)

	demGrid <- list(x = demData$lon, y = demData$lat, z = demData$demMat)
	if(is.regridDEM){
		demGrid <- interp.surface.grid(demGrid, list(x = xy.grid$lon, y = xy.grid$lat))
	}

	demres <- grdSp@grid@cellsize
	slpasp <- slope.aspect(demGrid$z, demres[1], demres[2], filter = "sobel")
	demGrid$slp <- slpasp$slope
	demGrid$asp <- slpasp$aspect

	ObjStn <- list(x = stnData$lon, y = stnData$lat, z = demGrid$z[ijTrain], slp = demGrid$slp[ijTrain], asp = demGrid$asp[ijTrain])

	gridObj <- list(NN = (function(){
						res.coarse <- sqrt((rad.lon*mean(grd.lon[-1]-grd.lon[-nlon0]))^2 + (rad.lat*mean(grd.lat[-1]-grd.lat[-nlat0]))^2)/2
						res.coarse <- if(res.coarse  >= 0.25) res.coarse else 0.25
						interp.grid <- createGrid(ObjStn, demGrid, as.dim.elv = TRUE, latlong = 'km',
											normalize = TRUE, coarse.grid = TRUE, res.coarse = res.coarse)
						xy.maxdist <- sqrt(sum((c(rad.lon, rad.lat)*(apply(coordinates(interp.grid$newgrid)[, c('lon', 'lat')], 2,
										function(x) diff(range(x)))/(c(nlon0, nlat0)-1)))^2))
						elv.grd <- range(demGrid$z, na.rm = TRUE)
						nelv <- length(seq(elv.grd[1], elv.grd[2], 100))
						nelv <- if(nelv > 1) nelv else 2
						z.maxdist <- rad.elv*(diff(range(coordinates(interp.grid$newgrid)[, 'elv']))/(nelv-1))
						xy.maxdist <- if(xy.maxdist < res.coarse) res.coarse else xy.maxdist
						maxdist <- sqrt(xy.maxdist^2 + z.maxdist^2)
						bGrd <- NULL
						interp.grid$coords.stn$alon <- interp.grid$coords.stn@coords[, 'lon']
						interp.grid$coords.stn$alat <- interp.grid$coords.stn@coords[, 'lat']
						interp.grid$coords.grd$alon <- interp.grid$coords.grd@coords[, 'lon']
						interp.grid$coords.grd$alat <- interp.grid$coords.grd@coords[, 'lat']
						if(!is.null(interp.grid$coords.rfe)){
							interp.grid$coords.rfe$alon <- interp.grid$coords.rfe@coords[, 'lon']
							interp.grid$coords.rfe$alat <- interp.grid$coords.rfe@coords[, 'lat']
						}
						interp.grid$newgrid$alon <- interp.grid$newgrid@coords[, 'lon']
						interp.grid$newgrid$alat <- interp.grid$newgrid@coords[, 'lat']
						interp.grid$newgrid <- interp.grid$newgrid[c(ijTrain, ijInt), ]
						retGrid <- list(interp.grid = interp.grid, xy.maxdist = xy.maxdist, z.maxdist = z.maxdist,
										maxdist = maxdist, bGrd = bGrd)
						return(retGrid)
					})(),
					IDWOK = (function(){
						res.coarse <- maxdist/2
						res.coarse <- if(res.coarse  >= 0.25) res.coarse else 0.25
						interp.grid <- createGrid(ObjStn, demGrid, as.dim.elv = FALSE, res.coarse = res.coarse)
						maxdist <- if(maxdist < res.coarse) res.coarse else maxdist
						cells <- SpatialPixels(points = interp.grid$newgrid, tolerance = sqrt(sqrt(.Machine$double.eps)))@grid
						bGrd <- createBlock(cells@cellsize, 2, 5)
						interp.grid$coords.stn$alon <- interp.grid$coords.stn@coords[, 'lon']
						interp.grid$coords.stn$alat <- interp.grid$coords.stn@coords[, 'lat']
						interp.grid$coords.grd$alon <- interp.grid$coords.grd@coords[, 'lon']
						interp.grid$coords.grd$alat <- interp.grid$coords.grd@coords[, 'lat']
						if(!is.null(interp.grid$coords.rfe)){
							interp.grid$coords.rfe$alon <- interp.grid$coords.rfe@coords[, 'lon']
							interp.grid$coords.rfe$alat <- interp.grid$coords.rfe@coords[, 'lat']
						}
						interp.grid$newgrid$alon <- interp.grid$newgrid@coords[, 'lon']
						interp.grid$newgrid$alat <- interp.grid$newgrid@coords[, 'lat']
						interp.grid$newgrid <- interp.grid$newgrid[c(ijTrain, ijInt), ]
						retGrid <- list(interp.grid = interp.grid, maxdist = maxdist, bGrd = bGrd)
						return(retGrid)
					})())

	#####################################################################################

	auxdf <- generateCombnation()
	bs.mthd <- paste(LMcomb$bias.method, LMcomb$bias.interp, LMcomb$bias.auxvar, sep = '_')
	lm.mthd <- paste(LMcomb$LMcoef.interp, LMcomb$LMcoef.auxvar, sep = '_')
	adj.dir <- file.path(adjDIR, bs.mthd)
	out.LM <- paste(bs.mthd, lm.mthd, sep = '-')
	LMcomb <- cbind(adj.dir, out.LM, LMcomb$LMcoef.interp, LMcomb$LMcoef.auxvar)

	#####################################################################################

	InsertMessagesTxt(main.txt.out, 'Compute LM Coefficients ...')

	retfor <- foreach(ll = seq(nrow(LMcomb)), .packages = packages, .export = toExports) %parLoop% {
		cblm <- LMcomb[ll, ]
		GeneralParameters$Interpolation.pars$interp.method <- if(cblm[3] == 'OK') 'Kriging' else cblm[3]
		auxv <- as.logical(auxdf[auxdf$l == cblm[4], c("dem", "slope", "aspect", "lon", "lat")])
		GeneralParameters$auxvar$dem <- auxv[1]
		GeneralParameters$auxvar$slope <- auxv[2]
		GeneralParameters$auxvar$aspect <- auxv[3]
		GeneralParameters$auxvar$lon <- auxv[4]
		GeneralParameters$auxvar$lat <- auxv[5]

		adjInfo <- ncFilesInfo(freqData, start.date, end.date, months, cblm[1], adjFFormat, errmsg)
		if(is.null(adjInfo)) return(NULL)

		origdir <- file.path(SPLM.coefDIR, cblm[2])
		dir.create(origdir, showWarnings = FALSE, recursive = TRUE)

		comptLMparams <- list(GeneralParameters = GeneralParameters, stnData = stnData, gridObj = gridObj,
							ijInt = ijInt, adjInfo = adjInfo, origdir = origdir)
		ret <- ComputeLMCoefRain.validation(comptLMparams)
	}
	if(closeklust) stopCluster(klust)

	InsertMessagesTxt(main.txt.out, 'Computing LM Coefficients finished')

	GeneralParameters <- NULL
	rm(demData, demGrid, stnData, gridObj, comptLMparams)

