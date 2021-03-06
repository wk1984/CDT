
##########xxxxxxxxxxxxxxxxxx Menu File xxxxxxxxxxxxxxxxxx##########

menu.file <- tkmenu(top.menu, tearoff = FALSE, relief = "flat")
tkadd(top.menu, "cascade", label = "File", menu = menu.file)

##########
tkadd(menu.file, "command", label = "Open data.frame", command = function(){
	tkconfigure(main.win, cursor = 'watch');tcl('update')
	dat.opfiles <- getOpenFiles(main.win, all.opfiles)
	tkconfigure(main.win, cursor = '')
	if(!is.null(dat.opfiles)){
		nopf <- length(AllOpenFilesType)
		AllOpenFilesType[[nopf+1]] <<- 'ascii'
		AllOpenFilesData[[nopf+1]] <<- dat.opfiles
	}else{
		return(NULL)
	}
})

##########
tkadd(menu.file, "command", label = "Open Netcdf file", command = function(){
	tkconfigure(main.win, cursor = 'watch'); tcl('update')
	nc.opfiles <- getOpenNetcdf(main.win, all.opfiles)
	tkconfigure(main.win, cursor = '')
	if(!is.null(nc.opfiles)){
		nopf <- length(AllOpenFilesType)
		AllOpenFilesType[[nopf+1]] <<- 'netcdf'
		AllOpenFilesData[[nopf+1]] <<- nc.opfiles
	}else{
		return(NULL)
	}
})

##########
tkadd(menu.file, "command", label = "Open ESRI Shapefile", command = function(){
	tkconfigure(main.win, cursor = 'watch'); tcl('update')
	shp.opfiles <- getOpenShp(main.win, all.opfiles)
	tkconfigure(main.win, cursor = '')
	if(!is.null(shp.opfiles)){
		nopf <- length(AllOpenFilesType)
		AllOpenFilesType[[nopf+1]] <<- 'shp'
		AllOpenFilesData[[nopf+1]] <<- shp.opfiles
	}else{
		return(NULL)
	}
})

##########
tkadd(menu.file, "separator")

##########
tkadd(menu.file, "command", label = "Open QC/Homogenization session", command = function(){
	refreshCDT.lcmd.env()
	spinbox.state()
	OpenOldCDTtask()
})

##########
tkadd(menu.file, "command", label = "Save QC/Homogenization session", command = function() saveCurrentCDTtask())

##########
tkadd(menu.file, "separator")

##########
tkadd(menu.file, "command", label = "Save table", command = function(){
	if(!is.null(ReturnExecResults)){
		tkconfigure(main.win, cursor = 'watch'); tcl('update')
		tab2sav <- try(SaveNotebookTabArray(tknotes), silent = TRUE)
		if(!inherits(tab2sav, "try-error")){
			InsertMessagesTxt(main.txt.out, "Table saved successfully")
		}else{
			InsertMessagesTxt(main.txt.out, "The table could not be saved", format = TRUE)
			InsertMessagesTxt(main.txt.out, gsub('[\r\n]', '', tab2sav[1]), format = TRUE)
			return(NULL)
		}
		tkconfigure(main.win, cursor = '')
	}else{
		return(NULL)
	}
 })

##########
tkadd(menu.file, "command", label = "Save table As...        ", command = function(){
	tabid <- as.numeric(tclvalue(tkindex(tknotes, 'current')))+1
	if(!is.na(tabid)){
		if(AllOpenTabType[[tabid]]%in%c("arr", "arrAssess")){
			filetypes <- "{{Text Files} {.txt .TXT}} {{CSV Files} {.csv .CSV}} {{All files} *}"
			if(Sys.info()["sysname"] == "Windows") file.to.save <- tclvalue(tkgetSaveFile(initialdir = getwd(), initialfile = "", filetypes = filetypes, defaultextension = TRUE))
			else file.to.save <- tclvalue(tkgetSaveFile(initialdir = getwd(), initialfile = "", filetypes = filetypes))
			Objarray <- AllOpenTabData[[tabid]][[2]]
			tkconfigure(main.win, cursor = 'watch'); tcl('update')
			dat2sav <- tclArray2dataframe(Objarray)
			colnoms <- if(AllOpenTabType[[tabid]] == "arr") TRUE else FALSE
			writeFiles(dat2sav, file.to.save, col.names = colnoms)
			tkconfigure(main.win, cursor = '')
		}else return(NULL)
	}else return(NULL)
})

##########
tkadd(menu.file, "command", label = "Save Image As...", command = function() SavePlot())

##########
tkadd(menu.file, "separator")

##########
tkadd(menu.file, "command", label = "Configurations", command = function() configCDT())

##########
tkadd(menu.file, "separator")

##########
tkadd(menu.file, "command", label = "Quit CDT", command = function(){
	on.exit({
		#sink(type = "message")
		#close(msgOUT)
		options(warn = 0)
	})
	tkdestroy(main.win)
})

##########xxxxxxxxxxxxxxxxxx Menu Data Preparation xxxxxxxxxxxxxxxxxx##########

menu.dataprep <- tkmenu(top.menu, tearoff = FALSE, relief = "flat")
tkadd(top.menu, "cascade", label = "Data Preparation", menu = menu.dataprep)

##########
tkadd(menu.dataprep, "command", label = "Format CDTs Input Data", command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('cdtInput.stn', 'daily')
	GeneralParameters <<- AggregateInputStationData(main.win, initpars)
})

##########
# tkadd(menu.dataprep, "separator")

tkadd(menu.dataprep, "command", label = "Merge two CDT data format", command = function(){
	refreshCDT.lcmd.env()
	if(is.null(lcmd.frame_merge2cdt)){
		lcmd.frame <<- merge2CDTDataPanelCmd()
		lcmd.frame_merge2cdt <<- 1
	}
})

##########
tkadd(menu.dataprep, "separator")

##########
tkadd(menu.dataprep, "command", label = "Assess Data Availability", command = function(){
	refreshCDT.lcmd.env()
	spinbox.state()
	if(is.null(lcmd.frame_assdata)){
		lcmd.frame <<- AssessDataPanelCmd()
		lcmd.frame_assdata <<- 1
	}
})

##########
tkadd(menu.dataprep, "separator")

##########
tkadd(menu.dataprep, "command", label = "Aggregating Time Series", command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('agg.ts', 'daily', TRUE)
	GeneralParameters <<- mainDialogAggTs(main.win, initpars)
})

##########
tkadd(menu.dataprep, "separator")

##########
tkadd(menu.dataprep, "command", label = "Download DEM", command = function(){
	getDEMFun(main.win)
})

##########
tkadd(menu.dataprep, "command", label = "Download Country boundary", command = function(){
	getCountryShapefile(main.win)
})

##########

tkadd(menu.dataprep, "command", label = "Download RFE data", command = function(){
	DownloadRFE(main.win)
})

##########
tkadd(menu.dataprep, "separator")

##########
tkadd(menu.dataprep, "command", label = "Filling missing dekadal temperature values", command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('fill.temp', 'dekadal')
	GeneralParameters <<- fillMissDekTemp(main.win, initpars)
})

# ##########
# tkadd(menu.dataprep, "separator")

# ##########
# tkadd(menu.dataprep, "command", label = "Data Conversion", command = function(){
# 	refreshCDT.lcmd.env()
# 	initpars <- initialize.parameters('data.convrs', 'dekadal')
# 	GeneralParameters <<- DataConversion(main.win, initpars)
# })

##########xxxxxxxxxxxxxxxxxx Menu Quality Control xxxxxxxxxxxxxxxxxx##########

menu.qchom <- tkmenu(top.menu, tearoff = FALSE, relief = "flat")
tkadd(top.menu, "cascade", label = "Quality Control", menu = menu.qchom)


##########
##check coordninates
tkadd(menu.qchom, "command", label = "Check Stations Coordinates", command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('chk.coords', 'daily')
	GeneralParameters <<- excludeOutStn(main.win, initpars)
})

##########
tkadd(menu.qchom, "separator")

##########
##QC one Run
menu.qc <- tkmenu(top.menu, tearoff = FALSE)
tkadd(menu.qchom, "cascade", label = "QC Check: One station", menu = menu.qc)


##########Rain
menu.qcRain <- tkmenu(menu.qc, tearoff = FALSE)
tkadd(menu.qc, "cascade", label = "Rainfall", menu = menu.qcRain)

##Zeros check
tkadd(menu.qcRain, "command", label = "False-Zeros check", command = function(){
	refreshCDT.lcmd.env()
	lchoixStnFr <<- selectStationCmd()
	initpars <- initialize.parameters('zero.check', 'daily')
	initpars$AllOrOne <- 'one'
	GeneralParameters <<- qcGetZeroCheckInfo(main.win, initpars)
})

##Outliers check
tkadd(menu.qcRain, "command", label = "Outliers Check", command = function(){
	refreshCDT.lcmd.env()
	lchoixStnFr <<- selectStationCmd()
	initpars <- initialize.parameters('qc.rain', 'daily', TRUE)
	initpars$AllOrOne <- 'one'
	GeneralParameters <<- qc.get.info.rain(main.win, initpars)
 })

##########
tkadd(menu.qc, "separator")

##########Temperatures
tkadd(menu.qc, "command", label = "Temperatures", command = function(){
	refreshCDT.lcmd.env()
	lchoixStnFr <<- selectStationCmd()
	initpars <- initialize.parameters('qc.temp', 'daily', TRUE)
	initpars$AllOrOne <- 'one'
	GeneralParameters <<- qc.get.info.txtn(main.win, initpars)
})

##########
##Qc all Run
menu.qc1 <- tkmenu(top.menu, tearoff = FALSE)
tkadd(menu.qchom, "cascade", label = "QC Check: All stations", menu = menu.qc1)

##########Rain
menu.qcRain1 <- tkmenu(menu.qc1, tearoff = FALSE)
tkadd(menu.qc1, "cascade", label = "Rainfall", menu = menu.qcRain1)

##Zeros check
tkadd(menu.qcRain1, "command", label = "False-Zeros check", command = function(){
	refreshCDT.lcmd.env()
	lchoixStnFr <<- selectStationCmd()
	initpars <- initialize.parameters('zero.check', 'daily')
	initpars$AllOrOne <- 'all'
	GeneralParameters <<- qcGetZeroCheckInfo(main.win, initpars)
})

##Outliers check
tkadd(menu.qcRain1, "command", label = "Outliers Check", command = function(){
	refreshCDT.lcmd.env()
	lchoixStnFr <<- selectStationCmd()
	initpars <- initialize.parameters('qc.rain', 'daily', TRUE)
	initpars$AllOrOne <- 'all'
	GeneralParameters <<- qc.get.info.rain(main.win, initpars)
 })

##########
tkadd(menu.qc1, "separator")

##########Temperatures
tkadd(menu.qc1, "command", label = "Temperatures", command = function(){
	refreshCDT.lcmd.env()
	lchoixStnFr <<- selectStationCmd()
	initpars <- initialize.parameters('qc.temp', 'daily', TRUE)
	initpars$AllOrOne <- 'all'
	GeneralParameters <<- qc.get.info.txtn(main.win, initpars)
})

##########
tkadd(menu.qchom, "separator")

##########
tkadd(menu.qchom, "command", label = "Aggregate zeros checked stations", command = function(){
	refreshCDT.lcmd.env()
	initpars <- init.params('agg.zc', 'daily')
	GeneralParameters <<- AggregateOutputStationData(main.win, initpars)
})


##########
tkadd(menu.qchom, "command", label = "Aggregate checked stations", command = function(){
	refreshCDT.lcmd.env()
	initpars <- init.params('agg.qc', 'daily')
	GeneralParameters <<- AggregateOutputStationData(main.win, initpars)
})

##########
tkadd(menu.qchom, "separator")

##########
# Menu homogenization

menu.homog <- tkmenu(top.menu, tearoff = FALSE)
tkadd(menu.qchom, "cascade", label = "Homogeneity Test", menu = menu.homog)

##########
###RHtestsV4
tkadd(menu.homog, "command", label = "RHtestsV4", command = function(){
	agreementfl <- file.path(apps.dir, 'configure', 'RHtestsV4_User_Agreement', fsep = .Platform$file.sep)
	if(file.exists(agreementfl)) proceed <- TRUE
	else{
		yesAgree <- RHtests_license()
		if(yesAgree){
			proceed <- TRUE
			cat("I Agree", file = agreementfl)
		}
		else proceed <- FALSE
	}
	if(proceed){
		GeneralParameters <<- initialize.parameters('rhtests', 'dekadal')
		refreshCDT.lcmd.env()
		lchoixStnFr <<- selectStationCmd()
		spinbox.state(state = 'normal')
		if(is.null(lcmd.frame_rhtests)){
			lcmd.frame <<- RHtestsV4Cmd()
			lcmd.frame_rhtests <<- 1
		}
	}
})

##########
tkadd(menu.homog, "separator")

#########
###Methods used by CDT
tkadd(menu.homog, "command", label = "CDT Homogenization Methods", command = function(){
	refreshCDT.lcmd.env()
	lchoixStnFr <<- selectStationCmd()
	initpars <- initialize.parameters('homog', 'dekadal')
	GeneralParameters <<- homogen.get.info(main.win, initpars)
})

##########
tkadd(menu.qchom, "command", label = "Aggregate homogenized stations", command = function(){
	refreshCDT.lcmd.env()
	initpars <- init.params('agg.hom', 'dekadal')
	GeneralParameters <<- AggregateOutputStationData(main.win, initpars)
})


##########xxxxxxxxxxxxxxxxxx Menu Merging Data xxxxxxxxxxxxxxxxxx##########

menu.mrg <- tkmenu(top.menu, tearoff = FALSE, relief = "flat")
tkadd(top.menu, "cascade", label = "Merging Data", menu = menu.mrg)

##########rain
menu.mrg.rain <- tkmenu(top.menu, tearoff = FALSE)
tkadd(menu.mrg, "cascade", label = "Merging Rainfall", menu = menu.mrg.rain)

##########
tkadd(menu.mrg.rain, "command", label = "Compute mean Gauge-RFE bias", background = 'lightblue', command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('coefbias.rain', 'dekadal')
	GeneralParameters <<- coefBiasGetInfoRain(main.win, initpars)
})

##########
tkadd(menu.mrg.rain, "separator")

##########
tkadd(menu.mrg.rain, "command", label = "Apply bias correction", command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('rmbias.rain', 'dekadal')
	GeneralParameters <<- rmvBiasGetInfoRain(main.win, initpars)
})

##########
tkadd(menu.mrg.rain, "separator")

##########
tkadd(menu.mrg.rain, "command", label = "Compute Spatio-temporal Trend Coefficients", background = 'lightblue', command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('coefLM.rain', 'dekadal')
	GeneralParameters <<- coefLMGetInfoRain(main.win, initpars)
})

##########
tkadd(menu.mrg.rain, "separator")

##########
tkadd(menu.mrg.rain, "command", label = "Merging Data", command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('merge.rain', 'dekadal')
	GeneralParameters <<- mergeGetInfoRain(main.win, initpars)
})

##########temperature
tkadd(menu.mrg, "separator")
menu.mrg.temp <- tkmenu(top.menu, tearoff = FALSE)
tkadd(menu.mrg, "cascade", label = "Merging Temperature", menu = menu.mrg.temp)

##########
tkadd(menu.mrg.temp, "command", label = "Compute Downscaling Coefficients", background = 'lightblue', command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('coefdown.temp', 'dekadal')
	GeneralParameters <<- coefDownGetInfoTemp(main.win, initpars)
})

##########
tkadd(menu.mrg.temp, "separator")

##########
tkadd(menu.mrg.temp, "command", label = "Reanalysis Downscaling", command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('down.temp', 'dekadal')
	GeneralParameters <<- downGetInfoDekTempReanal(main.win, initpars)
})

##########
tkadd(menu.mrg.temp, "separator")

##########
tkadd(menu.mrg.temp, "command", label = "Compute Bias Coefficients", background = 'lightblue', command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('coefbias.temp', 'dekadal')
	GeneralParameters <<- biasGetInfoTempDown(main.win, initpars)
})

##########
tkadd(menu.mrg.temp, "separator")

##########
tkadd(menu.mrg.temp, "command", label = "Apply bias correction", command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('adjust.temp', 'dekadal')
	GeneralParameters <<- adjGetInfoTempDownReanal(main.win, initpars)
})

##########
tkadd(menu.mrg.temp, "separator")

##########
tkadd(menu.mrg.temp, "command", label = "Compute Spatio-temporal Trend Coefficients", background = 'lightblue', command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('coefLM.temp', 'dekadal')
	GeneralParameters <<- coefLMGetInfoTemp(main.win, initpars)
})

##########
tkadd(menu.mrg.temp, "separator")

##########
tkadd(menu.mrg.temp, "command", label = "Merging Data", command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('merge.temp', 'dekadal')
	GeneralParameters <<- mrgGetInfoTemp(main.win, initpars)
})

##########
tkadd(menu.mrg, "separator")

##########
tkadd(menu.mrg, "command", label = "Updating dekadal Rainfall", command = function(){
	refreshCDT.lcmd.env()
	initpars <- initialize.parameters('merge.dekrain', 'dekadal')
	GeneralParameters <<- mergeDekadInfoRain(main.win, initpars)
})

##########xxxxxxxxxxxxxxxxxx Menu Data Processing xxxxxxxxxxxxxxxxxx##########

menu.dataproc <- tkmenu(top.menu, tearoff = FALSE, relief = "flat")
tkadd(top.menu, "cascade", label = "Data Processing", menu = menu.dataproc)

##########
tkadd(menu.dataproc, "command", label = "Spatial  Interpolation", command = function(){
	refreshCDT.lcmd.env()
	spinbox.state(state = 'normal')
	if(is.null(lcmd.frame_interpol)){
		lcmd.frame <<- InterpolationPanelCmd()
		lcmd.frame_interpol <<- 1
	}
})

##########
tkadd(menu.dataproc, "separator")

##########
menu.valid <- tkmenu(top.menu, tearoff = FALSE)
tkadd(menu.dataproc, "cascade", label = "Validation", menu = menu.valid)

########
# Precipitation validation
tkadd(menu.valid, "command", label = "Precipitation", command = function(){
	refreshCDT.lcmd.env()
	spinbox.state(state = 'normal')
	if(is.null(lcmd.frame_valid)){
		lcmd.frame <<- ValidationPanelCmd('RR')
		lcmd.frame_valid <<- 1
	}
})

##########
tkadd(menu.valid, "separator")

#########
# Temperature validation
tkadd(menu.valid, "command", label = "Temperature", command = function(){
	refreshCDT.lcmd.env()
	spinbox.state(state = 'normal')
	if(is.null(lcmd.frame_valid)){
		lcmd.frame <<- ValidationPanelCmd('TT')
		lcmd.frame_valid <<- 1
	}
})

##########
tkadd(menu.dataproc, "separator")

##########
tkadd(menu.dataproc, "command", label = "Data Extraction", command = function(){
	refreshCDT.lcmd.env()
	spinbox.state(state = 'normal')
	if(is.null(lcmd.frame_extrdata)){
		lcmd.frame <<- ExtractDataPanelCmd()
		lcmd.frame_extrdata <<- 1
	}
})

# ##########
# tkadd(menu.dataproc, "separator")

# ##########
# menu.stats <- tkmenu(top.menu, tearoff = FALSE)
# tkadd(menu.dataproc, "cascade", label = "Statistical Analysis", state = 'disabled', menu = menu.stats)

# ########
# # Time series analysis
# tkadd(menu.stats, "command", label = "Time Series", command = function(){
# return(NULL)
# })

# ##########
# tkadd(menu.stats, "separator")

# #########
# # spatial 
# tkadd(menu.stats, "command", label = "Spatial Statistics", state = 'disabled', command = function(){
# return(NULL)
# })


##########xxxxxxxxxxxxxxxxxx Menu Plot Data xxxxxxxxxxxxxxxxxx##########

menu.plot <- tkmenu(top.menu, tearoff = FALSE, relief = "flat")
tkadd(top.menu, "cascade", label = "Plot Data", menu = menu.plot)

##########
tkadd(menu.plot, "command", label = "Plot CDT data format", command = function(){
	refreshCDT.lcmd.env()
	spinbox.state(state = 'normal')
	if(is.null(lcmd.frame_CDTffrtPlot)){
		lcmd.frame <<- PlotCDTDataFormatCmd()
		lcmd.frame_CDTffrtPlot <<- 1
	}
})

##########
tkadd(menu.plot, "separator")

##########
tkadd(menu.plot, "command", label = "Plot NetCDF gridded data", command = function(){
	refreshCDT.lcmd.env()
	spinbox.state(state = 'normal')
	if(is.null(lcmd.frame_grdNcdfPlot)){
		lcmd.frame <<- PlotGriddedNcdfCmd()
		lcmd.frame_grdNcdfPlot <<- 1
	}
})

##########
tkadd(menu.plot, "separator")

##########
tkadd(menu.plot, "command", label = "Plot Merging Outputs", command = function(){
	refreshCDT.lcmd.env()
	spinbox.state(state = 'normal')
	if(is.null(lcmd.frame_mergePlot)){
		lcmd.frame <<- PlotMergingOutputCmd()
		lcmd.frame_mergePlot <<- 1
	}
})

##########xxxxxxxxxxxxxxxxxx Menu help xxxxxxxxxxxxxxxxxx##########

menu.aide <- tkmenu(top.menu, tearoff = FALSE, relief = "flat")
tkadd(top.menu, "cascade", label = "Help", menu = menu.aide)

##########
tkadd(menu.aide, "command", label = "CDT User Guide", command = function(){
	browseURL(paste0('file://',file.path(apps.dir, 'help', 'html', 'index.html', fsep = .Platform$file.sep)))
})

##########
tkadd(menu.aide, "separator")

##########
tkadd(menu.aide, "command", label = "About CDT", command = function() aboutCDT())

########
