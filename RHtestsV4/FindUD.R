
FindUD<-function(InSeries,InCs,output,station,MissingValueCode=-99,p.lev=0.95,
                 Iadj=10000,Mq=10,Ny4a=0,GUI=FALSE){

 #######################################################
Station<-paste('BaseSeries_',station,sep='')

  Debug<-TRUE
#  ErrorMSG<-NA
#  assign("ErrorMSG",ErrorMSG,envir=.GlobalEnv)

  flog<-paste(output,".log",sep="")

  Nmin<-10
  if(Ny4a>0&Ny4a<=5) Ny4a<-5
  if(!p.lev%in%c(0.75,0.8,0.9,0.95,0.99,0.9999)){
	InsertMessagesTxt(main.txt.out,paste("FindU: input p.lev",p.lev,"error"),format=TRUE)
	#cat(paste("FindU: input p.lev",p.lev,"error"),'\n')
#      ErrorMSG<<-paste("FindU: input p.lev",p.lev,"error\n",
#                 get("ErrorMSG",env=.GlobalEnv),"\n")
#      if(!GUI) cat(ErrorMSG)
      return(-1)
  }
  plev<-p.lev
  pkth<-match(p.lev,c(0.75,0.8,0.9,0.95,0.99,0.9999))
  assign("Nmin",Nmin,envir=.GlobalEnv)
  itmp<-Read(InSeries,MissingValueCode)
  if(itmp<0){
	InsertMessagesTxt(main.txt.out,paste("FindUD: Error in read data from",Station),format=TRUE)
	#cat(paste("FindUD: Error in read data from",Station),'\n')
#    ErrorMSG<<-paste("FindUD: Error in read data from",Station,"\n",
#               get("ErrorMSG",env=.GlobalEnv),"\n")
#    if(!GUI) cat(ErrorMSG)
    return(-1)
  }
  N<-length(Y0); Nadj<-Ny4a*Nt
  readPFtable(N,pkth)
  itmp<-readLines(InCs)
  Pk0<-Pk.PMFT(N)
  oout<-rmCycle(itable)
  Y1<-oout$Base
  EB<-oout$EB
  assign("EB",EB,envir=.GlobalEnv)
  if(length(EB)!=length(Icy)) {
	InsertMessagesTxt(main.txt.out,"Annual cycle length (from non-missing data) differ from original dataset",format=TRUE)
	#cat("Annual cycle length (from non-missing data) differ from original dataset",'\n')
#    ErrorMSG<<-paste("Annual cycle length (from non-missing data) differ from original dataset",
#                     "\n",get("ErrorMSG",env=.GlobalEnv),"\n")
#    if(!GUI) cat(ErrorMSG)
    return(-1)
  }



##########################################################
## define output file

  ofileIout<-paste(output,"_pCs.txt",sep="")
  ofileMout<-paste(output,"_mCs.txt",sep="")
  file.create(ofileIout)

  ofileAout<-paste(output,"_UD.dat",sep="")
  ofilePdf<-paste(output,"_UD.pdf",sep="")
  ofileSout<-paste(output,"_UDstat.txt",sep="")
  file.create(ofileAout)
  file.create(ofilePdf)
  file.create(ofileSout)

####################################################
###write "_UDstat.txt"

  cat(paste("The nominal level of confidence (1-alpha)=",plev,"\n"),file=ofileSout)
  cat(paste("Input data filename:", Station,"N=",N,"\n"),file=ofileSout,append=T)

  Ip0<-N
  oout<-LSmultiRedCycle(Y1,Ti,Ip0,1)
  beta0<-oout$trend
  betaL0<-oout$betaL
  betaU0<-oout$betaU
  meanhat0<-oout$meanhat
  Ehat0<-mean(meanhat0)
  p.tr0<-oout$p.tr
  corD<-oout$cor
  corDL<-oout$corl
  corDU<-oout$corh

  if(length(itmp)<2){ # no input changepoints
    oout<-PMFT(Y1,Ti,Pk0)
    I0<-0
    I2<-oout$KPx
    I4<-N
    oout1<-PMFxKxI0I2(Y1,Ti,I0,I2)
    I1<-oout1$Ic
    oout2<-PMFxKxI0I2(Y1,Ti,I2,I4)
    I3<-oout2$Ic
    oout3<-PMFxKxI0I2(Y1,Ti,I1,I3)
    I2<-oout3$Ic

    Ns<-1
    Ips<-c(I1,N)
    if(I1>0){
      otmp<-LSmultiple(Y1,Ti,Ips)
      resi<-otmp$resi
      fitted<-otmp$fitted
      otmp<-Rphi(resi,Ips,Ns)
      cor1<-otmp$cor
      corL1<-otmp$corl
      corU1<-otmp$corh
      W<-otmp$W+fitted
      otmp<-PMFxKc(Y1,Ti,I0,I4,I1)
      PFx1<-otmp$PFc
      otmp<-PMFxKc(W,Ti,I0,I4,I1)
      prob1<-otmp$prob
    }
    else{
      prob1<-0
      PFx1<-0
    }

    Ips<-c(I2,N)
    if(I2>0){
      otmp<-LSmultiple(Y1,Ti,Ips)
      resi<-otmp$resi
      fitted<-otmp$fitted
      otmp<-Rphi(resi,Ips,Ns)
      cor2<-otmp$cor
      corL2<-otmp$corl
      corU2<-otmp$corh
      W<-otmp$W+fitted
      otmp<-PMFxKc(Y1,Ti,I0,I4,I2)
      PFx2<-otmp$PFc
      otmp<-PMFxKc(W,Ti,I0,I4,I2)
      prob2<-otmp$prob
    }
    else{
      prob2<-0
      PFx2<-0
    }

    Ips<-c(I3,N)
    if(I3>0){
      otmp<-LSmultiple(Y1,Ti,Ips)
      resi<-otmp$resi
      fitted<-otmp$fitted
      otmp<-Rphi(resi,Ips,Ns)
      cor3<-otmp$cor
      corL3<-otmp$corl
      corU3<-otmp$corh
      W<-otmp$W+fitted
      otmp<-PMFxKc(Y1,Ti,I0,I4,I3)
      PFx3<-otmp$PFc
      otmp<-PMFxKc(W,Ti,I0,I4,I3)
      prob3<-otmp$prob
    }
    else{
      prob3<-0
      PFx3<-0
    }

    tmp<-sort(c(PFx1,PFx2,PFx3),decreasing=T,index.return=T)
    PFx.mx<-tmp$x[1]
    prob.mx<-c(prob1,prob2,prob3)[tmp$ix[1]]
    Imx<-c(I1,I2,I3)[tmp$ix[1]]


####################################################
###write "_pCs.txt"


    if(prob.mx<plev){
#     cat("PMF finds the series to be homogeneous!\n",file=ofileIout)
      cat(paste(0,"changepoints in Series", Station,"\n"),file=ofileIout)

	InsertMessagesTxt(main.txt.out,paste("PMF finds the series",station," to be homogeneous!"))
     # cat("PMF finds the series to be homogeneous!\n")


#     return()
      Ns<-0
      Ips<-N
      Ids<-c(0)
    }
    else{
      Ns<-1
      Ips<-c(Imx,N)
      Ids<-c(0,1)
    }
  }
  else{
    Ns<-length(itmp)-1
    Ips<-c(rep(0,Ns),N)
    Ids<-rep(0,Ns)
    for(i in 1:Ns){ # using YYYYMMDD as index, searching for the largest
                    # date less or equal to given YYYYMMDD
      ymdtmp<-as.numeric(substr(itmp[i+1],7,16))
      it<-match(ymdtmp,IY0)
      if(!is.na(it)) Ips[i]<-it
      else Ips[i]<-max(c(1:N)[IY0<=ymdtmp])
      Ids[i]<-as.numeric(substr(itmp[i+1],1,1))
    }
    if(sum(is.na(Ips))>0|!identical(Ips,sort(Ips))){
#      ErrorMSG<<-paste("FindUD: Ips read in from ",basename(InCs),"error:")
	for(i in 1:Ns)
		InsertMessagesTxt(main.txt.out,paste("FindUD: Ips read in from ",basename(InCs),"error:",Ips[i]),format=TRUE)
		#cat(paste("FindUD: Ips read in from ",basename(InCs),"error:",Ips[i]),'\n')
#		ErrorMSG<<-paste(get("ErrorMSG",env=.GlobalEnv),Ips[i])
#		ErrorMSG<<-paste(get("ErrorMSG",env=.GlobalEnv),"\n")
#		if(!GUI) cat(ErrorMSG)
      	return(-1)
    }
  }

  if(Ns>0){
  Ips.i<-Ips
  Niter<-0
# start search for all possible changepoints
  tt<-TRUE
  while(tt){
    Niter<-Niter+1
    tt<-FALSE
    Ips0<-NULL
    for(i in 1:(Ns+1)){
      I0<- if(i==1) 0 else Ips[i-1]
      I2<-Ips[i]
      otmp<-PMFxKxI0I2(Y1,Ti,I0,I2)
      if(otmp$prob>0) Ips0<-sort(c(Ips0,otmp$Ic))
    }
# estimate p-value of each changepoint in series Ips0, find the most significant
# changepoint Iseg.mx
    tt1<-TRUE
    while(tt1){
      if(length(Ips0)==0) tt1<-FALSE
      else{
        Iseg.mx<-0
	prob.mx<-(-1)
	probL.mx<-(-1)
	PFx.mx<-(-1)
        for(i in 1:length(Ips0)){
	  Ips1<-sort(c(Ips,Ips0[i]))
	  ith<-match(Ips0[i],Ips1)
	  otmp<-PMFxIseg(Y1,Ti,Ips1,ith)
	  probL<-min(c(otmp$probL,otmp$probU,otmp$prob))
	  probU<-max(c(otmp$probL,otmp$probU,otmp$prob))
	  PFx<-otmp$PFx
	  if(probU<plev) Ips0[i]<-0
	  else
	    if(PFx>PFx.mx){
	      prob.mx<-otmp$prob
	      probL.mx<-probL
	      Iseg.mx<-Ips0[i]
	      PFx.mx<-PFx
	    }
	}
	if(probL.mx>=plev){
	  Ips<-sort(c(Ips,Iseg.mx))
	  Ns<-Ns+1
	  Ips0<-Ips0[Ips0!=Iseg.mx]
	  tt<-TRUE
	}
	else tt1<-FALSE
	Ips0<-Ips0[Ips0!=0]
      }
    }
  }
  Ids0<-rep(NA,length(Ips))
  for(i in 1:length(Ips)){
    if(Ips[i]%in%Ips.i) Ids0[i]<-Ids[Ips.i==Ips[i]]
    else Ids0[i]<-0
  }
  Ids<-Ids0
# Ids<-as.integer(Ips%in%Ips.i)
  tt<-TRUE
  while(tt){
    tt<-FALSE
    probL.mn<-9999
    Iseg.mn<-0
    for(i in 1:Ns){
      if(Ids[i]==0){ # check those un-documented
        Ips0<-Ips[-i]
        otmp<-PMFxIseg(Y1,Ti,Ips,i)
        probL<-min(otmp$probL,otmp$probU)
        if(probL<probL.mn){
          Iseg.mn<-i
          probL.mn<-probL
        }
      } # end if documented
    }
    if(Iseg.mn>0&probL.mn<plev){
      Ips<-Ips[-Iseg.mn]
      Ids<-Ids[-Iseg.mn]
      Ns<-Ns-1
      if(Ns>0) tt<-TRUE
    }
  }
  }
# all changepoints are significant, calculate stats and output

  if(Ns>0) {
    Nsegs<-Ips-c(0,Ips[1:Ns])
    Iseg.longest<-sort(Nsegs,index=T,decreasing=T)$ix[1]
  }
  else Iseg.longest<-0

  if(Iadj>(Ns+1)|Iseg.longest==0) Iseg.adj<-Ns+1
  else if(Iadj==0)Iseg.adj<-Iseg.longest
  else Iseg.adj<-Iadj

  otmp<-LSmultiRedCycle(Y1,Ti,Ips,Iseg.adj)
  Y1<-otmp$Y0
  cor<-otmp$cor
  corl<-otmp$corl
  corh<-otmp$corh
  df<-(N-2-Nt-Ns)
  pcor<-pt(abs(cor)*sqrt(df/(1-cor^2)),df)
  Rf<-otmp$resi
  W<-otmp$W
  WL<-otmp$WL
  WU<-otmp$WU
  EB1<-otmp$EB

  itmp1<-cbind(EB1,Icy)
  itmp2<-cbind(1:N,Imd)
  colnames(itmp2)<-c("idx","Icy")
  itmp<-merge(itmp1,itmp2,by="Icy")
  EBfull<-itmp[order(itmp[,"idx"]),"EB1"]
  EEB<-mean(EB1,na.rm=T)

  if(Ns>0){
    Rb<-Y1-otmp$trend*Ti+EBfull
    QMout<-QMadjGaussian(Rb,Ips,Mq,Iseg.adj,Nadj)
    B<-QMout$PA


####################################################
###write "_UDstat.txt"

    cat(paste("Nseg_shortest =",QMout$Nseg.mn,"; Mq = ",QMout$Mq,"; Ny4a = ",Ny4a,"\n"),
        file=ofileSout,append=T)
    cat(paste("\n Adjust to segment", Iseg.adj,": from",
        if(Iseg.adj==1) 1 else Ips[Iseg.adj-1]+1,
        "to",Ips[Iseg.adj],"\n"),file=ofileSout,append=T)
#   cat("#Fcat, DP (CDF and Differnces in category mean)\n",file=ofileSout,
#       append=T)
    oline<-paste('#Fcat: frequency category boundaries\n',
                 '#DP: Difference in the category means\n#',sep='')
    for(i in 1:Ns) oline<-paste(oline,paste('Fcat.Seg',i,sep=''),paste('DP.Seg',i,sep=''))
    oline<-paste(oline,'\n')
    cat(oline,file=ofileSout,append=T)

    write.table(round(QMout$osmean,4),file=ofileSout,append=T,
                row.names=F,col.names=F)
    for(i in 1:(Ns+1)){
      I1<-if(i==1) 1 else Ips[i-1]+1
      I2<-Ips[i]
      if(i!=Iseg.adj)
      cat(paste("Seg. ",i,": mean of QM-adjustments =",round(mean(QMout$W[I1:I2]),4),
          "\n",sep=""),file=ofileSout,append=T)
    }
  }
  else B<-Y1-otmp$trend*Ti+EBfull

  adj<-otmp$Y0+EBfull
# B<-B+EBfull+otmp$trend*Ti
  B<-B+otmp$trend*Ti

####################################################
###write "_UDstat.txt"

  cat(file=ofileSout,paste(" Ignore changepoints -> trend0 =",
      round(beta0,6),"(",round(betaL0,6),",",round(betaU0,6),") (p=",
      round(p.tr0,4),"); cor=", round(corD,4),"(",round(corDL,4),
      ",",round(corDU,4),")\n"),append=T)
  cat("Common trend TPR fit to the seasonal-cycle-adjusted Base series:\n",
      file=ofileSout,append=T)
  cat(paste("#steps= ",Ns,"; trend=",round(otmp$trend,6),"(",
            round(otmp$betaL,6),",",round(otmp$betaU,6),") (p=",
            round(otmp$p.tr,4),"); cor=",
            round(cor,4),"(",round(corl,4),",",round(corh,4),")",
	    round(pcor,4),"\n"),
	    file=ofileSout,append=T)
  if(Ns>0) for(i in 1:Ns){
    I1<-if(i==1) 1 else Ips[i-1]+1
    I2<-Ips[i]
    Delta<-otmp$mu[Iseg.adj]-otmp$mu[i]
    adj[I1:I2]<-adj[I1:I2]+Delta
    stepsize<-otmp$mu[i+1]-otmp$mu[i]
    cat(paste(Ips[i],IY0[Ips[i]],"stepsize=",round(stepsize,4),"\n"),
        file=ofileSout,append=T)
  }

  oR<-Y1-otmp$meanhat
  oR[2:N]<-oR[2:N]-oR[1:(N-1)]*cor
  Ehat<-mean(otmp$meanhat)
  meanhat0<-meanhat0-Ehat0+Ehat



#####################################################################################
##PLOT


  pdf(file=ofilePdf,onefile=T)
  op <- par(no.readonly = TRUE) # the whole list of settable par's.
  par(mfrow=c(2,1))
  par(mar=c(3,4,3,2)+.1,cex.main=.8,cex.lab=.8,cex.axis=.8,cex=.8)

  uyrs<-unique(floor(ori.itable[,1]/10))*10
  labels<-NULL
  ats<-NULL
  for(i in 1:length(uyrs)){
    if(!is.na(match(uyrs[i],ori.itable[,1]))){
      labels<-c(labels,uyrs[i])
      ats<-c(ats,match(uyrs[i],ori.itable[,1]))
    }
  }

  pdata<-rep(NA,dim(ori.itable)[1])
  pdata[ooflg]<-otmp$Y0
  plot(1:dim(ori.itable)[1],pdata,type="l",xlab="",ylab="",
       ylim=c(min(otmp$Y0,otmp$meanhat),max(otmp$Y0,otmp$meanhat)),
       xaxt="n",col="black",lwd=0.5,
       main="Base anomaly series and regression fit")
  axis(side=1,at=ats,labels=labels)
  pdata[ooflg]<-otmp$meanhat
  lines(1:dim(ori.itable)[1],pdata,col="red")

  pdata[ooflg]<-otmp$Y0+EBfull
  plot(1:dim(ori.itable)[1],pdata,type="l",xlab="",ylab="",
       ylim=c(min(otmp$Y0+EBfull,otmp$meanhat+EEB),
              max(otmp$Y0+EBfull,otmp$meanhat+EEB)),
       xaxt="n",col="black",lwd=0.5,
       main="Base series and regression fit")
  axis(side=1,at=ats,labels=labels)

  pdata[ooflg]<-otmp$meanhat+EEB
  lines(1:dim(ori.itable)[1],pdata,col="red")

  pdata[ooflg]<-adj
  plot(1:dim(ori.itable)[1],pdata,type="l",xlab="",ylab="",
       ylim=c(min(c(adj,B)),max(c(adj,B))),
       xaxt="n",col="black",lwd=0.5,
       main="Mean-adjusted base series")
  axis(side=1,at=ats,labels=labels)

  pdata[ooflg]<-B
  plot(1:dim(ori.itable)[1],pdata,type="l",xlab="",ylab="",
       ylim=c(min(c(adj,B)),max(c(adj,B))),
       xaxt="n",col="black",lwd=0.5,
       main="QM-adjusted base series")
  axis(side=1,at=ats,labels=labels)

  # test plot
  if(Ns>0){
    par(mar=c(4,5,3,2)+.1,cex=.8,mfrow=c(2,2),mgp=c(1.2,.5,0))
    col=0
    np<-0
    osp<-QMout$osp
    osmean<-QMout$osmean
    for(i in 1:(Ns+1)){
      Fd<-.5/QMout$Mq
      I1<-if(i==1) 1 else Ips[i-1]+1
      I2<-Ips[i]
      ymax<-max(osp[,2:3],na.rm=T); ymin<-min(osp[,2:3],na.rm=T)
      if(i!=Iseg.adj){
        np<-np+1
        if(col==0) {
          col<-2
	  plot(osp[I1:I2,2],osp[I1:I2,3],xlim=c(0,1),ylim=c(ymin,ymax),
	       type="l",lwd=1,col=col,xlab="Cumulative Frequency",
	       ylab="QM Adjustment")
          title(cex.main=0.9,main=paste("distribution of QM adjustments with Mq=",QMout$Mq),line=0.5)
	  icol<-2*np
	  for(j in 1:QMout$Mq){
	    lines(c(osmean[(j+1),icol]-Fd,osmean[(j+1),icol]+Fd),
	          c(rep(osmean[(j+1),(icol+1)],2)),col=col,lty=2,lwd=.5)
	    if(j>=1&j<QMout$Mq) lines(rep(osmean[(j+1),icol]+Fd,2),
	          c(osmean[(j+1),(icol+1)],osmean[(j+2),(icol+1)]),col=col,lty=2,lwd=.5)
	  }
        }
        else{
          col<-col+1
	  lines(osp[I1:I2,2],osp[I1:I2,3],lwd=1,col=col)
	  icol<-2*np
	  for(j in 1:QMout$Mq){
	    lines(c(osmean[(j+1),icol]-Fd,osmean[(j+1),icol]+Fd),
	          c(rep(osmean[(j+1),(icol+1)],2)),col=col,lty=2,lwd=.5)
	    if(j>=1&j<QMout$Mq) lines(rep(osmean[(j+1),icol]+Fd,2),
	          c(osmean[(j+1),(icol+1)],osmean[(j+2),(icol+1)]),col=col,lty=2,lwd=.5)
	  }
        }
        text(.15,ymax-np*(ymax-ymin)/(Ns*3),paste("Seg.",i))
        lines(c(.25,.30),rep(ymax-np*(ymax-ymin)/(Ns*3),2),lwd=2,col=col)
      }
      else np<-np+1
    }
  }

  par(op)
  dev.off()

#####################################################################################


  odata<-matrix(NA,dim(ori.itable)[1],10)
# odata[ooflg,1]<-Ti
  odata[,1]<-c(1:dim(ori.itable)[1])
  odata[,2]<-ori.itable[,1]*10000+ori.itable[,2]*100+ori.itable[,3]
# odata[ooflg,3]<-round(otmp$Y0+EBfull,4)
  odata[,3]<-ori.itable[,4]
  odata[ooflg,4]<-round(otmp$meanhat+EEB,4)
  odata[ooflg,5]<-round(adj,4)
  odata[ooflg,6]<-round(otmp$Y0,4)
  odata[ooflg,7]<-round(otmp$meanhat,4)
  odata[ooflg,8]<-round(otmp$meanhat+EBfull,4)
  odata[ooflg,9]<-round(B,4)
# odata[ooflg,9]<-round(oR,4)
# odata[ooflg,10]<-round(Rb,4)
  odata[ooflg,10]<-round(meanhat0,4)

  Imd1<-ori.itable[,2]*100+ori.itable[,3]
  if(sum(is.na(ori.itable[,4])==F&Imd1==229)>0){
    if(Ns>0){
      tdata<-ori.itable[is.na(ori.itable[,4])==F,]
      IY1<-tdata[,1]*10000+tdata[,2]*100+tdata[,3]
      Ips.ymd<-IY0[Ips]
      Ips.1<-rep(NA,Ns+1)
      for(i in 1:Ns) Ips.1[i]<-c(1:length(IY1))[IY1==Ips.ymd[i]]
      Ips.1[Ns+1]<-length(IY1)
#     Ips.1<-c(1:length(IY1))[Ips.ymd==IY1]
      Imd2<-tdata[,2]*100+tdata[,3]
      Ids.leap<-c(1:length(Imd2))[Imd2==229]
      Nl<-length(Ids.leap)
      Rb<-Y1-otmp$trend*Ti+EBfull
      Rb1<-tdata[,4]; Rb1[-Ids.leap]<-Rb
      Ti1<-rep(NA,length(IY1)); Ti1[-Ids.leap]<-Ti
      for(i in 1:length(Ids.leap)) {
        Rb1[Ids.leap[i]]<-tdata[Ids.leap[i],4]+Rb1[Ids.leap[i]-1]-tdata[Ids.leap[i]-1,4]
        Ti1[Ids.leap[i]]<-Ti1[Ids.leap[i]-1]
      }
      B1<-QMadjGaussian(Rb1,Ips.1,Mq,Iseg.adj,Nadj)$PA
      B1<-B1+otmp$trend*Ti1
      B1.leap<-B1[Ids.leap]
      odata[is.na(odata[,3])==F&Imd1==229,9]<-round(B1.leap,4)
    }
    else
      odata[Imd1==229,9]<-odata[Imd1==229,3]
    Ids.leapo<-c(1:dim(ori.itable)[1])[is.na(ori.itable[,4])==F&Imd1==229]
    for(jth in 1:length(Ids.leapo)){
      kth<-Ids.leapo[jth]
      if(Ns>0){
        k1th<-if(odata[kth-1,2]%in%IY0[Ips]) (kth+1) else (kth-1)
      }
      else k1th<-kth-1
      for(pth in c(4,7,8,10)) odata[kth,pth]<-odata[k1th,pth]
      for(pth in c(5,6)){delta1<-odata[k1th,3]-odata[k1th,pth]; odata[kth,pth]<-odata[kth,3]-delta1}
    }
  }

####################################################
###write "_UD.dat"

  write.table(file=ofileAout,odata,na=as.character(MissingValueCode),col.names=F,row.names=F)

####################################################


  otmp<-LSmultiple(W,Ti,Ips)
  RW<-otmp$resi
  otmp<-LSmultiple(WL,Ti,Ips)
  RWL<-otmp$resi
  otmp<-LSmultiple(WU,Ti,Ips)
  RWU<-otmp$resi


####################################################
###write "_pCs.txt"

  if(Ns==0) {
#   cat("PMF finds the series to be homogeneous!\n",file=ofileIout)
    cat(paste(Ns,"changepoints in Series", Station,"\n"),file=ofileIout)

	#InsertMessagesTxt(main.txt.out,"PMF finds the series to be homogeneous!")
    cat("PMF finds the series to be homogeneous!\n")
#   return()
  }
  else{
    cat(paste(Ns,"changepoints in Series", Station,"\n"),
        file=ofileIout)

    for(i in 1:Ns){
      I1<- if(i==1) 1 else Ips[i-1]+1
      I3<-Ips[i+1]
      Ic<-Ips[i]
      Id<-Ids[i]
      Nseg<-I3-I1+1

      PFx95<-getPFx95(cor,Nseg)
      PFx95L<-getPFx95(corl,Nseg)
      PFx95U<-getPFx95(corh,Nseg)
      SSEf.Iseg<-sum(Rf[I1:I3]^2)
      Ips0<-Ips[-i]
      otmp<-LSmultiple(Y1,Ti,Ips0)
      SSE0.Iseg<-sum(otmp$resi[I1:I3]^2)
      Fx<-(SSE0.Iseg-SSEf.Iseg)*(Nseg-3)/SSEf.Iseg
      Pk0<-Pk.PMFT(Nseg)
      PFx<-Fx*Pk0[Ic-I1+1]

      otmp<-LSmultiple(W,Ti,Ips0)
      SSE0.Iseg<-sum(otmp$resi[I1:I3]^2)
      SSEf.Iseg<-sum(RW[I1:I3]^2)
      Fx<-(SSE0.Iseg-SSEf.Iseg)*(Nseg-3)/SSEf.Iseg
      if(Fx<=0){
        PFx<-0
        Fx<-0
        prob<-0
      }
      else prob<-pf(Fx,1,Nseg-3)

      otmp<-LSmultiple(WL,Ti,Ips0)
      SSE0.Iseg<-sum(otmp$resi[I1:I3]^2)
      SSEf.Iseg<-sum(RWL[I1:I3]^2)
      Fx<-(SSE0.Iseg-SSEf.Iseg)*(Nseg-3)/SSEf.Iseg
      probL0<-if(Fx<0) 0 else pf(Fx,1,Nseg-3)

      otmp<-LSmultiple(WU,Ti,Ips0)
      SSE0.Iseg<-sum(otmp$resi[I1:I3]^2)
      SSEf.Iseg<-sum(RWU[I1:I3]^2)
      Fx<-(SSE0.Iseg-SSEf.Iseg)*(Nseg-3)/SSEf.Iseg
      probU0<-if(Fx<0) 0 else pf(Fx,1,Nseg-3)

      probL<-min(probL0,probU0)
      probU<-max(probL0,probU0)

      if(Id==0) { # type-0 changepoints
        if(probU<plev) Idc<-"No  "
        else if(probL<plev&probU>=plev) Idc<-"?   "
        else if(probL>=plev) Idc<-"YifD"
	if(PFx>=PFx95U) Idc<-"Yes "
      }
      else if(Id==1) { # type-1 changepoints
        if(PFx<PFx95L) Idc<-"No  "
        else if(PFx>=PFx95L&PFx<PFx95U) Idc<-"?   "
        else if(PFx>=PFx95U) Idc<-"Yes "
      }

####################################################
###write "_pCs.txt"

      cat(paste(sprintf("%1.0f",as.numeric(Id))," ",
              sprintf("%-4.4s",Idc),
              sprintf("%10.0f",IY0[Ic])," (",
              sprintf("%6.4f",probL),"-",
              sprintf("%6.4f",probU),")",
	      sprintf("%6.3f",plev),
	      sprintf("%10.4f",PFx)," (",
	      sprintf("%10.4f",PFx95L),"-",
	      sprintf("%10.4f",PFx95U),")\n",sep=""),
	      file=ofileIout,
	      append=TRUE)

####################################################
###write "_UDstat.txt"

      cat(paste("PMF : c=", sprintf("%4.0f",Ic),
    	      "; (Time ", sprintf("%10.0f",IY0[Ic]),
	      "); Type= ",sprintf("%4.0f",as.numeric(Id)),
              "; p=", sprintf("%10.4f",prob),
	      "(", sprintf("%10.4f",probL),
	      "-", sprintf("%10.4f",probU),
	      "); PFmax=", sprintf("%10.4f",PFx),
	      "; CV95=",sprintf("%10.4f",PFx95),
	      "(", sprintf("%10.4f",PFx95L),
	      "-", sprintf("%10.4f",PFx95U),
	      "); Nseg=", sprintf("%4.0f",Nseg),"\n",sep=""),
	      file=ofileSout, append=T)
    }
  }
  if(GUI)
    return(0)
  else{
    file.copy(from=ofileIout,to=ofileMout,overwrite=TRUE)
    #cat("FindUD finished successfully...\n")
	InsertMessagesTxt(main.txt.out,paste("FindUD finished successfully for",station))
    return(0)
  }
}

