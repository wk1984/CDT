
rm(list = ls(all = TRUE))
library(tools)
if(getRversion() < "3.0.0") stop("Need R  >= 3.0.0")
apps.dir <<- dirname(parent.frame(2)$ofile)
imgdir <<- file.path(apps.dir, 'images', fsep = .Platform$file.sep)

pkgs <- c('R.utils', 'stringr', 'jsonlite', 'tkrplot', 'gmt', 'fields', 'latticeExtra', 'sp', 'maptools',
			'gstat', 'automap', 'reshape2', 'ncdf4', 'foreach', 'doParallel', 'raster', 'rgdal', 'rgeos',
			'RCurl', 'fitdistrplus', 'qmap', 'ADGofTest')
new.pkgs <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
if(length(new.pkgs) > 0){
	if(Sys.info()["sysname"] == "Windows") {
		locdir <- readline(prompt = "Install Packages Local Directory (yes/no): ")
		rep <- substr(gsub("^\\s+|\\s+$", "", tolower(locdir)), 1, 1)
		if(rep == 'y' | rep  == 'o'){
			dirpath <- readline(prompt = "Full path to the directory containing the packages: ")
			path2pkgs <- gsub("^\\s+|\\s+$", "", dirpath)
			if(file.exists(path2pkgs)){
				write_PACKAGES(path2pkgs)
				install.packages(new.pkgs, contriburl = file.path("file://", path2pkgs))
			}else stop(paste(path2pkgs, 'does not exist.'))
		}else install.packages(new.pkgs)
	}else{
		if(!any(c('rgdal', 'rgeos')%in%new.pkgs)){
			install.packages(new.pkgs)
		}else{
			new.pkgs1 <- new.pkgs[!new.pkgs%in%c('rgdal', 'rgeos')]
			if(length(new.pkgs1) > 0) install.packages(new.pkgs1)
			if('rgeos'%in%new.pkgs){
				geos_config <- readline(prompt = "Path to geos-config ('/opt/local/bin/geos-config'): ")
				geos_config <- gsub("^\\s+|\\s+$", "", geos_config)
				if(geos_config  == "") geos_config <- '/opt/local/bin/geos-config'
				if(!file.exists(geos_config)) stop('geos-config: command not found')
				install.packages('rgeos', type = "source", configure.args = paste('--with-geos-config=', geos_config, sep = ''))
			}
			if('rgdal'%in%new.pkgs){
				gdal_config <- readline(prompt = "Path to gdal-config ('/opt/local/bin/gdal-config'): ")
				gdal_config <- gsub("^\\s+|\\s+$", "", gdal_config)
				if(gdal_config  == "") gdal_config <- '/opt/local/bin/gdal-config'
				if(!file.exists(gdal_config)) stop('gdal-config: command not found')
				proj_include <- readline(prompt = "Path to PROJ.4 include ('/opt/local/include'): ")
				proj_include <- gsub("^\\s+|\\s+$", "", proj_include)
				if(proj_include  == "") proj_include <- '/opt/local/include'
				if(!file.exists(proj_include)) stop('PROJ installation not found')
				proj_lib <- readline(prompt = "Path to PROJ.4 lib ('/opt/local/lib'): ")
				proj_lib <- gsub("^\\s+|\\s+$", "", proj_lib)
				if(proj_lib  == "") proj_lib <- '/opt/local/lib'
				if(!file.exists(proj_lib)) stop('PROJ installation not found')
				install.packages('rgdal', type = "source", 
						 configure.args = c(paste('--with-proj-include=', proj_include, sep = ''),
											paste('--with-proj-lib=', proj_lib, sep = ''),
											paste('--with-gdal-config=', gdal_config, sep = '')))
			}
		}
	}
}

library(stringr)
library(jsonlite)

tclpathF <- file.path(apps.dir, 'configure', 'configure_default.json')
tclPath <- fromJSON(tclpathF)
cdtVersion <<- str_trim(tclPath$CDT_Version)
if(tclPath$UseOtherTclTk == 1){
	if(Sys.info()["sysname"] == "Windows") {
		tclbin <- str_trim(tclPath$Windows$Tclbin)
		tcllib <- str_trim(tclPath$Windows$Tcllib)
	}else if(Sys.info()["sysname"] == "Darwin") {
		tclbin <- str_trim(tclPath$MacOS$Tclbin)
		tcllib <- str_trim(tclPath$MacOS$Tcllib)
	}else if(Sys.info()["sysname"] == "Linux") {
		tclbin <- str_trim(tclPath$Linux$Tclbin)
		tcllib <- str_trim(tclPath$Linux$Tcllib)
	}else{
		stop("Operating system: Unknown")
	}
	Sys.setenv(MY_TCLTK = tclbin)
	Sys.setenv(TCL_LIBRARY = tcllib)
	library.dynam("tcltk", "tcltk", .libPaths(), DLLpath = tclbin)
}

#########Load library

packages <- list('tcltk', 'tkrplot', 'grid', 'lattice', 'latticeExtra', 'sp', 'ncdf4', 'gmt', 'fields',
				'gstat', 'automap', 'reshape2', 'compiler', 'parallel', 'foreach', 'doParallel',
				'raster', 'rgeos', 'rgdal', 'maptools', 'RCurl', 'fitdistrplus', 'qmap', 'ADGofTest')
ret.pkgs <- sapply(packages, library, character.only = TRUE, logical.return = TRUE)
#compilePKGS(enable = TRUE)
#enableJIT(3)

nb_cores <- detectCores()-1
doparallel <- if(nb_cores < 2) FALSE else TRUE
# `%parLoop%` <- if(nb_cores<2) `%do%` else `%dopar%`
options(warn = -1)

if (Sys.info()["sysname"] == "Windows"){
	is.noImg <- tclRequire("Img")
	if(is.logical(is.noImg)){
		tkmessageBox(message = "Tcl package 'Img' not found", icon = "error", type = "ok")
		stop("Tcl package 'Img' not found")
	}
}

############


# Start.CDT.GUI <- function(){

	source(file.path(apps.dir, 'functions', 'cdtConfiguration_function.R'))
	confpath <- file.path(apps.dir, 'configure', 'configure_user.json')

	if(file.exists(confpath)){
		conffile <- fromJSON(confpath)
		workdir <- str_trim(conffile$working.directory)
		if(file.exists(workdir)) setwd(workdir)
		else{
			workdir <- path.expand('~')
			setwd(workdir)
			conffile$working.directory <- workdir
			write_json(conffile, confpath)
		}
		if(!file.exists(str_trim(conffile$Tktable.path)) | !file.exists(str_trim(conffile$Bwidget.path))){
			configCDT()
		}else{
			addTclPath(path = str_trim(conffile$Tktable.path))
			addTclPath(path = str_trim(conffile$Bwidget.path))
			tclRequire("Tktable")
			tclRequire("BWidget")
		}
	}else{
		configCDT()
	}
	source(file.path(apps.dir, 'functions', 'cdtMain_window.R', fsep = .Platform$file.sep))


# }
# ############
# retCDT <- Start.CDT.GUI()


