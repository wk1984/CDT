plotOutliers <- function(jmo){
	if(GeneralParameters$AllOrOne == 'one'){
		IJoutputdir <- ReturnExecResults$outputdir
		IJstation <- ReturnExecResults$station
	}
	if(GeneralParameters$AllOrOne == 'all'){
		ijstn <- which(as.character(GeneralParameters$parameter[[2]][,1]) == tclvalue(lchoixStnFr$env$stn.choix.val))
		IJoutputdir <- ReturnExecResults$outputdir[[ijstn]]
		IJstation <- ReturnExecResults$station[[ijstn]]
	}

	outlparams <- getOutlier.params(IJstation, IJoutputdir)

	if(!is.null(outlparams)){
		outqcf <- outlparams$qcout
		xdates <- outlparams$dates
		xdat <- outlparams$value
		opar <- par(mar = c(3,4,3,1))

		outdates <- as.character(outqcf$dates)
		if(GeneralParameters$action == 'qc.rain') outlq <- as.character(outqcf$upper.outlier)
		if(GeneralParameters$action == 'qc.temp') outlq <- as.character(outqcf$outlier.check)
		outdates1 <- outdates[!is.na(outlq)]
		moqc <- substr(outdates1, 5,6)
		moval <- substr(xdates, 5,6)
		idqc <- which(moqc == jmo)

		idm <- which(moval == jmo)
		datym <- xdates[idm]
		valm <- xdat[idm]

		if(GeneralParameters$period == 'daily'){
			datym1st <- which(substr(datym, 7,8) == '01')
			datymid <- which(substr(datym, 7,8) == '15')
			if(GeneralParameters$action == 'qc.rain'){
				ylab <- 'Daily rainfall [mm]'
			}
			if(GeneralParameters$action == 'qc.temp'){
				if(Sys.info()["sysname"] == "Windows") ylab <- expression(paste("Daily", ifelse(as.character(GeneralParameters$test.tx) == '1', 'maximum', 'minimum') ,"temperature[ " * degree, 'C]'))
				else ylab <- paste('Daily', ifelse(as.character(GeneralParameters$test.tx) == '1', 'maximum', 'minimum') ,'temperature [°C]')
			}
			xlabels <- format(as.Date(datym[datymid], format='%Y%m%d'), '%Y')
		}
		if(GeneralParameters$period == 'dekadal'){
			datym1st <- which(substr(datym, 7,7) == '1')
			datymid <- which(substr(datym, 7,7) == '2')
			if(GeneralParameters$action == 'qc.rain'){
				ylab <- 'Dekadal rainfall [mm]'
			}
			if(GeneralParameters$action == 'qc.temp'){
				if(Sys.info()["sysname"] == "Windows") ylab <- expression(paste("Dekadal", ifelse(as.character(GeneralParameters$test.tx) == '1', 'maximum', 'minimum') ,"temperature[ " * degree, 'C]'))
				else ylab <- paste('Dekadal', ifelse(as.character(GeneralParameters$test.tx) == '1', 'maximum', 'minimum') ,'temperature [°C]')
			}
			xlabels <- format(as.Date(datym[datymid], format='%Y%m%d'), '%Y')
		}
		if(GeneralParameters$period == 'monthly'){
			datym1st <- 1:length(datym)
			datymid <- 1:length(datym)
			if(GeneralParameters$action == 'qc.rain'){
				ylab <- 'Monthly rainfall [mm]'
			}
			if(GeneralParameters$action == 'qc.temp'){
				if(Sys.info()["sysname"] == "Windows") ylab <- expression(paste("Monthly", ifelse(as.character(GeneralParameters$test.tx) == '1', 'maximum', 'minimum') ,"temperature[ " * degree, 'C]'))
				else ylab <- paste('Monthly', ifelse(as.character(GeneralParameters$test.tx) == '1', 'maximum', 'minimum') ,'temperature [°C]')
			}
			xlabels <- format(as.Date(paste(datym, '15', sep = ''), format='%Y%m%d'), '%Y')
		}

		if(sum(!is.na(valm)) > 0)  ylim <- c(min(valm, na.rm = T), max(valm, na.rm = T))
		else ylim <- if(sum(!is.na(xdat)) == 0) c(0,1) else c(min(xdat, na.rm = T), max(xdat, na.rm = T))

		plot(valm, type = 'n', xaxt = 'n', lwd = 2, ylab = ylab, xlab='',ylim = ylim)
		abline(h = axTicks(2), col = "lightgray", lty = "dotted")
		abline(v = datym1st, col = "lightgray", lty = "dotted")
		lines(valm, type = 'h')

		if(length(idqc) > 0){
			datyq <- outdates1[idqc]
			imatch <- match(datyq, datym)
			points(imatch, valm[imatch], col = 2)
			lines(imatch, valm[imatch], col = 2, lwd = 2.5, type = 'h')
		}
		axis(side = 1, at = datymid, labels = xlabels, tck = 0)
		title(main = format(ISOdate(2014, jmo, 1), "%B"), cex.main = 1.5, font.main = 1.5)

		plt <- par("plt")
		usr <- par("usr")
		par(opar)
		return(list(plt = plt, usr = usr, dates = datym))
	}else return(NULL)
}

#################################################################################################


DisplayOutliers <- function(parent, jmo, noteQcOutlierCheck){

	if(GeneralParameters$AllOrOne == 'one'){
		IJstation <- ReturnExecResults$station
	}
	if(GeneralParameters$AllOrOne == 'all'){
		ijstn <- which(as.character(GeneralParameters$parameter[[2]][,1]) == tclvalue(lchoixStnFr$env$stn.choix.val))
		IJstation <- ReturnExecResults$station[[ijstn]]
	}

	########PLOT
	pltusr <- NULL
	plotIt <- function(){
		op <- par(bg = "white")
		pltusr <<- plotOutliers(jmo)
		par(op)
	}
	###################################################################
		if(is.null(noteQcOutlierCheck)){
			onglet <- addNewTab(parent, tab.title = paste(IJstation, format(ISOdate(2014, jmo, 1), "%b"),'Outliers Check', sep = '-'))
		}else{
			ntab <- length(AllOpenTabType)
			if(ntab > 0){
				AllNoteTab <- sapply(1:ntab, function(j){
					if(!is.null(attributes(AllOpenTabData[[j]][[1]][[1]]))) AllOpenTabData[[j]][[1]][[1]]$ID
					else AllOpenTabData[[j]][[1]][[1]]
				})
				idTabs <- which(AllNoteTab == noteQcOutlierCheck[[2]])

				if(length(idTabs) > 0){
					onglet <- noteQcOutlierCheck[[1]]
					tkdestroy(AllOpenTabData[[idTabs]][[2]])
					tcl(tknotes, 'tab', AllOpenTabData[[idTabs]][[1]][[1]],'-text',
					paste(IJstation, format(ISOdate(2014, jmo, 1), "%b"),'Outliers Check   ',sep = '-'))
				}else{
					onglet <- addNewTab(parent, tab.title = paste(IJstation, format(ISOdate(2014, jmo, 1), "%b"),'Outliers Check', sep = '-'))
				}
			}else{
				onglet <- addNewTab(parent, tab.title = paste(IJstation, format(ISOdate(2014, jmo, 1), "%b"),'Outliers Check', sep = '-'))
			}
		}

	#########
	hscale <- as.numeric(tclvalue(tkget(spinH)))
	vscale <- as.numeric(tclvalue(tkget(spinV)))

	#tcl("update", "idletasks")
	img <- tkrplot(onglet[[2]], fun = plotIt, hscale = hscale, vscale = vscale)
	tkgrid(img)
	tkgrid.rowconfigure(img, 0, weight = 1)
	tkgrid.columnconfigure(img, 0, weight = 1)
	tcl("update")
	parPlotSize <- pltusr$plt
	usrCoords <- pltusr$usr

	if(GeneralParameters$period == 'monthly'){
		dates <- as.Date(paste(pltusr$dates, '15', sep = ''), format='%Y%m%d')
	}else{
		dates <- as.Date(pltusr$dates, format='%Y%m%d')
	}


	display.cursor.type <- function(x, y){
		xmouse <- as.numeric(x)
		ymouse <- as.numeric(y)

		imgw <- as.numeric(tclvalue(tkwinfo("reqwidth", img)))
		imgh <- as.numeric(tclvalue(tkwinfo("reqheight", img)))

		imgmw <- as.numeric(tclvalue(tkwinfo("width", img)))
		imgmh <- as.numeric(tclvalue(tkwinfo("height", img)))

		posimgx <- round((imgmw-imgw)/2)
		posimgy <- round((imgmh-imgh)/2)
		orgx <- ifelse(posimgx < 0,0, posimgx)
		orgy <- ifelse(posimgy < 0,0, posimgy)

		xpos<-(xmouse-orgx)/imgw
		ypos <- 1-(ymouse-orgy)/imgh

		xplt1 <- parPlotSize[1]
		xplt2 <- parPlotSize[2]
		yplt1 <- parPlotSize[3]
		yplt2 <- parPlotSize[4]

		minX <- usrCoords[1]
		rangeX <- usrCoords[2]-usrCoords[1]
		minY <- usrCoords[3]
		rangeY <- usrCoords[4]-usrCoords[3]

		xcoord <- minX+(xpos-xplt1)*rangeX/(xplt2-xplt1)
		ycoord <- minY+(ypos-yplt1)*rangeY/(yplt2-yplt1)

		ipos <- as.integer(round(xcoord))

		if(GeneralParameters$period == 'monthly'){
			labdates <- format(dates[ipos],'%b-%Y')
		}else if(GeneralParameters$period == 'dekadal'){
			labdates <- substr(format(dates[ipos],'%d-%b-%Y'), 2,11)
		}else if(GeneralParameters$period == 'daily'){
			labdates <- format(dates[ipos],'%d-%b-%Y')
		}

		frxcoord <- ifelse(ipos < 1 | ipos > length(dates) | ycoord < usrCoords[3] | ycoord > usrCoords[4],'',labdates)
		frycoord <- ifelse(xcoord < usrCoords[1] | xcoord > usrCoords[2] | ycoord < usrCoords[3] | ycoord > usrCoords[4],'',round(ycoord, 1))

		tclvalue(xpcoord) <- frxcoord
		tclvalue(ypcoord) <- frycoord
	}

	tkbind(img,"<Enter>", function() tkconfigure(img, cursor = 'crosshair'))
	tkbind(img,"<Leave>", function() tkconfigure(img, cursor=''))
	tkbind(img, "<Motion>", function(x, y){
		display.cursor.type(x, y)
	})

	return(list(onglet, img))
}

