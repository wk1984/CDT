
FindU<-function(InSeries,output,station,MissingValueCode=-99,p.lev=0.95,
                Iadj=10000,Mq=10,Ny4a=0,GUI=FALSE){

#####################################################
Station<-paste('BaseSeries_',station,sep='')

#  ErrorMSG<-NA
#  assign("ErrorMSG",ErrorMSG,envir=.GlobalEnv)
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
  if(itmp==(-1)){
	InsertMessagesTxt(main.txt.out,paste("FindU: Error in read data from",Station),format=TRUE)
	#cat(paste("FindU: Error in read data from",Station),'\n')
#    ErrorMSG<<-paste("FindU: Error in read data from",Station,"\n",
#               get("ErrorMSG",env=.GlobalEnv),"\n")
#    if(!GUI) cat(ErrorMSG)
    return(-1)
  }


##########################################################
## define output file

  ofileAout<-paste(output,"_U.dat",sep="")
  ofilePdf<-paste(output,"_U.pdf",sep="")
  ofileSout<-paste(output,"_Ustat.txt",sep="")
  file.create(ofileAout)
  file.create(ofilePdf)
  file.create(ofileSout)


#########################################################

  N<-length(Y0); Nadj<-Ny4a*Nt

####################################################
###write "_Ustat.txt"

  cat(paste("The nominal level of confidence (1-alpha)=",plev,"\n"),file=ofileSout)
  cat(paste("Input data filename:", Station, "N=",N, "\n"),file=ofileSout,append=T)
  readPFtable(N,pkth)
  Pk0<-Pk.PMFT(N)
  oout<-rmCycle(itable)
  Y1<-oout$Base
  EB<-oout$EB
  assign("EB",EB,envir=.GlobalEnv)
  if(length(EB)!=length(Icy)) {
	InsertMessagesTxt(main.txt.out,paste("Annual cycle length (from non-missing data) differ from original dataset"),format=TRUE)
	#cat(paste("Annual cycle length (from non-missing data) differ from original dataset"),'\n')
#    ErrorMSG<<-paste("Annual cycle length (from non-missing data) differ from original dataset",
#                     "\n",get("ErrorMSG",env=.GlobalEnv),"\n")
#    if(GUI==F) print(ErrorMSG)
    return(-1)
  }

  Ip0<-N
  otmp<-LSmultiRedCycle(Y1,Ti,Ip0,1)
  beta0<-otmp$trend
  meanhat0<-otmp$meanhat
  Ehat0<-mean(meanhat0)

####################################################
###write "_Ustat.txt"

  cat(file=ofileSout,paste(" Ignore changepoints -> trend0 =",
      round(beta0,6),"(",round(otmp$betaL,6),",",round(otmp$betaU,6),")",
      "(p=",round(otmp$p.tr,4),"); cor=",
      round(otmp$cor,4),"(", round(otmp$corl,4),",",
      round(otmp$corh,4),")\n"),append=T)

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
    cor1<-0
    corL1<-0
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
    cor2<-0
    corL2<-0
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
    cor3<-0
    corL3<-0
  }


######################################################################
## define output file

  ofileIout<-paste(output,"_1Cs.txt",sep="")
  ofileMout<-paste(output,"_mCs.txt",sep="")
  file.create(ofileIout)

#####################################################################

  tmp<-sort(c(PFx1,PFx2,PFx3),decreasing=T,index.return=T)
  PFx.mx<-tmp$x[1]
  prob.mx<-c(prob1,prob2,prob3)[tmp$ix[1]]
  Imx<-c(I1,I2,I3)[tmp$ix[1]]
  cor.mx<-c(corL1,corL2,corL3)[tmp$ix[1]]
  PFx95L<-getPFx95(cor.mx,N)
  if(PFx.mx<PFx95L){
    Ns<-0
    Ips<-N

####################################################
###write "_1Cs.txt"

    cat(paste(Ns,"changepoints in Series", Station,
              paste("sample:(",sprintf("%1.0f",1)," ",sprintf("%-4.4s","YifD"),
	       sprintf("%10.0f",19000101),")",sep=""),"\n"),file=ofileIout)

	InsertMessagesTxt(main.txt.out,paste("PMF finds no Type-1 changepoints in the series",station))
    #cat("PMF finds no Type-1 changepoints in the series!\n")
  }

  else{
  Ns<-1
  Ips<-c(Imx,N)

# if(Debug) cat(file=flog,c("First Ips:",Ips,"\n"))
  tt<-TRUE
  Niter<-0
  while(tt){  # condition on is there any more Bps to insert in Ips?
    Niter<-Niter+1
    tt<-FALSE
    Ips0<-NULL
    for(i in 1:(Ns+1)){ # search for new break points
      I0<- if(i==1) 0 else Ips[i-1]
      I2<-Ips[i]
      otmp<-PMFxKxI0I2(Y1,Ti,I0,I2)
      if(otmp$prob>0) Ips0<-sort(c(Ips0,otmp$Ic))
    }
#   if(Debug) {
#     cat(file=flog,paste("Niter",Niter,"new Ips:",length(Ips0),"\n"),append=T)
#     cat(file=flog,c(Ips0,"\n"),append=T)
#     cat(file=flog,paste("Niter",Niter,"old Ns",Ns," "),append=T)
#   }
 # finished search for possible new changepoints, start estimate the p-value
 # of the Ips0 series and find the most significant changepoint Iseg.mx
    tt1<-TRUE
    while(tt1){
      PFx.mx<-(-9999)
      Iseg.mx<-0
      PFx95L.mx<-0
      if(length(Ips0)==0) tt1<-FALSE
      else{
        for(i in 1:length(Ips0)){
	  Ips1<-sort(c(Ips,Ips0[i]))
	  ith<-match(Ips0[i],Ips1)
	  otmp<-PMFxIseg(Y1,Ti,Ips1,ith)
	  if(otmp$PFx<otmp$PFx95L) Ips0[i]<-0
	  else
	    if(otmp$PFx>PFx.mx){
	      PFx.mx<-otmp$PFx
	      Iseg.mx<-Ips0[i]
	      PFx95L.mx<-otmp$PFx95L
	    }
	}
	if(PFx.mx>=PFx95L.mx){
	  Ips<-sort(c(Ips,Iseg.mx))
	  Ns<-Ns+1
	  Ips0<-Ips0[Ips0!=Iseg.mx]
	  tt<-TRUE
	}
	else tt1<-FALSE
	Ips0<-Ips0[Ips0!=0]
      }
    }
#   if(Debug) cat(file=flog,paste("new Ns:", Ns,"\n"),append=T)
  }
# finish finding any possible new changepoints
# start to delete the least significant changepoint if it is insignificant

  tt<-TRUE
  while(tt){
    tt<-FALSE
    Iseg.mn<-0
    PFx.mn<-99999
    PFx95L.mn<-99999
    for(i in 1:Ns){
      otmp<-PMFxIseg(Y1,Ti,Ips,i)
      if(otmp$PFx<PFx.mn){
        Iseg.mn<-i
	PFx.mn<-otmp$PFx
	PFx95L.mn<-otmp$PFx95L
      }
    }
    if(Iseg.mn>0&PFx.mn<PFx95L.mn){
      Ips<-Ips[-Iseg.mn]
      Ns<-Ns-1
      if(Ns>0) tt<-TRUE
    }
  }

  }
# end of detection
  if(Ns>0) {
    Nsegs<-Ips-c(0,Ips[1:Ns])
    Iseg.longest<-sort(Nsegs,index=T,decreasing=T)$ix[1]
  }
  else Iseg.longest<-0

  if(Iadj>(Ns+1)|Iseg.longest==0) Iseg.adj<-Ns+1
  else if(Iadj==0)Iseg.adj<-Iseg.longest
  else Iseg.adj<-Iadj

  oout<-LSmultiRedCycle(Y1,Ti,Ips,Iseg.adj)
  Y1<-oout$Y0
  cor<-oout$cor
  corl<-oout$corl
  corh<-oout$corh
  df<-(N-2-Nt-Ns)
  pcor<-pt(abs(cor)*sqrt(df/(1-cor^2)),df)
  W<-oout$W
  WL<-oout$WL
  WU<-oout$WU
  EB1<-oout$EB
  itmp1<-cbind(EB1,Icy)
  itmp2<-cbind(1:N,Imd)
  colnames(itmp2)<-c("idx","Icy")
  itmp<-merge(itmp1,itmp2,by="Icy")
  EBfull<-itmp[order(itmp[,"idx"]),"EB1"]
  EEB<-mean(EB1,na.rm=T)


####################################################
###write "_Ustat.txt"


  if(Ns>0){
    Rb<-Y1-oout$trend*Ti+EBfull
    QMout<-QMadjGaussian(Rb,Ips,Mq,Iseg.adj,Nadj)
    B<-QMout$PA
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
  else B<-Y1-oout$trend*Ti+EBfull

# itmp1<-cbind(EB1,Icy)
# itmp2<-cbind(1:N,Imd)
# colnames(itmp2)<-c("idx","Icy")
# itmp<-merge(itmp1,itmp2,by="Icy")
# EBfull<-itmp[order(itmp[,"idx"]),"EB1"]
# EEB<-mean(EB1,na.rm=T)
  adj<-oout$Y0+EBfull
# B<-B+EBfull+oout$trend*Ti
  B<-B+oout$trend*Ti

####################################################
###write "_Ustat.txt"


  cat("Common trend TPR fit to the de-seasonalized Base series:\n",
      file=ofileSout,append=T)
  cat(paste("#steps= ",Ns,"; trend=",round(oout$trend,6),"(",
            round(oout$betaL,6),",",round(oout$betaU,6),") (p=",
            round(oout$p.tr,4),"); cor=",
            round(cor,4),"(",round(corl,4),",",round(corh,4),")",
	    round(pcor,4),"\n"),
	    file=ofileSout,append=T)
  if(Ns>0) for(i in 1:Ns){
    I1<-if(i==1) 1 else Ips[i-1]+1
    I2<-Ips[i]
    Delta<-oout$mu[Iseg.adj]-oout$mu[i]
    adj[I1:I2]<-adj[I1:I2]+Delta
    stepsize<-oout$mu[i+1]-oout$mu[i]
    cat(paste(Ips[i],IY0[Ips[i]],"stepsize=",round(stepsize,4),"\n"),
        file=ofileSout,append=T)
  }

  oR<-Y1-oout$meanhat
  oR[2:N]<-oR[2:N]-oR[1:(N-1)]*cor
  Ehat<-mean(oout$meanhat)
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
  pdata[ooflg]<-oout$Y0
  plot(1:dim(ori.itable)[1],pdata,type="l",xlab="",ylab="",
       ylim=c(min(oout$Y0,oout$meanhat),max(oout$Y0,oout$meanhat)),
       xaxt="n",col="black",lwd=0.5,
       main="Base anomaly series and regression fit")
  axis(side=1,at=ats,labels=labels)
  pdata[ooflg]<-oout$meanhat
  lines(1:dim(ori.itable)[1],pdata,col="red")

  pdata[ooflg]<-oout$Y0+EBfull
  plot(1:dim(ori.itable)[1],pdata,type="l",xlab="",ylab="",
       ylim=c(min(oout$Y0+EBfull,oout$meanhat+EEB),
              max(oout$Y0+EBfull,oout$meanhat+EEB)),
       xaxt="n",col="black",lwd=0.5,
       main="Base series and regression fit")
  axis(side=1,at=ats,labels=labels)
  pdata[ooflg]<-oout$meanhat+EEB
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
          title(cex.main=0.9,main=paste("distribution of QM adjustments with Mq=",QMout$Mq),line=.5)
	  icol<-2*np
	  for(j in 1:QMout$Mq){
	    lines(c(osmean[(j+1),icol]-Fd,osmean[(j+1),icol]+Fd),
	          c(rep(osmean[(j+1),(icol+1)],2)),col=col,lty=2,lwd=.5)
	    if(j>=1&j<QMout$Mq) lines(rep(osmean[(j+1),icol]+Fd,2),
	          c(osmean[(j+1),(icol+1)],osmean[(j+2),(icol+1)]),col=col,lty=2,lwd=0.5)
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
	          c(osmean[(j+1),(icol+1)],osmean[(j+2),(icol+1)]),col=col,lty=2,lwd=0.5)
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
# odata[ooflg,3]<-round(oout$Y0+EBfull,4)
  odata[,3]<-ori.itable[,4]
  odata[ooflg,4]<-round(oout$meanhat+EEB,4)
  odata[ooflg,5]<-round(adj,4)
  odata[ooflg,6]<-round(oout$Y0,4)
  odata[ooflg,7]<-round(oout$meanhat,4)
  odata[ooflg,8]<-round(oout$meanhat+EBfull,4)
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
      Rb<-Y1-oout$trend*Ti+EBfull
      Rb1<-tdata[,4]; Rb1[-Ids.leap]<-Rb
      Ti1<-rep(NA,length(IY1)); Ti1[-Ids.leap]<-Ti
      for(i in 1:length(Ids.leap)) {
        Rb1[Ids.leap[i]]<-tdata[Ids.leap[i],4]+Rb1[Ids.leap[i]-1]-tdata[Ids.leap[i]-1,4]
        Ti1[Ids.leap[i]]<-Ti1[Ids.leap[i]-1]
      }
      B1<-QMadjGaussian(Rb1,Ips.1,Mq,Iseg.adj,Nadj)$PA
      B1<-B1+oout$trend*Ti1
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
#write data *_U.dat
  write.table(file=ofileAout,odata,na=as.character(MissingValueCode),
	col.names=F,row.names=F)


####################################################

  otmp<-LSmultiple(Y1,Ti,Ips)
  resi<-otmp$resi
  otmpW<-LSmultiple(W,Ti,Ips)
  resiW<-otmpW$resi
  otmpWL<-LSmultiple(WL,Ti,Ips)
  resiWL<-otmpWL$resi
  otmpWU<-LSmultiple(WU,Ti,Ips)
  resiWU<-otmpWU$resi


####################################################
###write "_1Cs.txt"

  if(Ns==0) {
    cat(paste(Ns,"changepoints in Series", Station,
              paste("sample:(",sprintf("%1.0f",1)," ",sprintf("%-4.4s","YifD"),
	       sprintf("%10.0f",19000101),")",sep=""),"\n"),file=ofileIout)
	InsertMessagesTxt(main.txt.out,paste("PMF finds no Type-1 changepoints in the series",station))
    #cat("PMF finds no Type-1 changepoints in the series!\n")
  }
  else{

    cat(paste(Ns,"changepoints in Series", Station,"\n"),
        file=ofileIout)
    for(i in 1:Ns){
      I1<- if(i==1) 1 else Ips[i-1]+1
      Ic<-Ips[i]
      I3<-Ips[i+1]
      Nseg<-I3-I1+1
      PFx95<-getPFx95(cor,Nseg)
      PFx95l<-getPFx95(corl,Nseg)
      PFx95h<-getPFx95(corh,Nseg)
      SSEf.Iseg<-sum(resi[I1:I3]^2)
      Ips1<-Ips[-i]
      otmp1<-LSmultiple(Y1,Ti,Ips1)
      SSE0.Iseg<-sum(otmp1$resi[I1:I3]^2)
      Fx<-(SSE0.Iseg-SSEf.Iseg)*(Nseg-3)/SSEf.Iseg
      Pk1<-Pk.PMFT(Nseg)
      PFx<-Fx*Pk1[Ic-I1+1]

      SSEf.Iseg<-sum(resiW[I1:I3]^2)
      otmp1<-LSmultiple(W,Ti,Ips1)
      SSE0.Iseg<-sum(otmp1$resi[I1:I3]^2)
      Fx<-(SSE0.Iseg-SSEf.Iseg)*(Nseg-3)/SSEf.Iseg
      if(Fx>0) prob<-pf(Fx,1,Nseg-3)
      else{
        Fx<-0
        prob<-0
        PFx<-0
      }

      SSEf.Iseg<-sum(resiWL[I1:I3]^2)
      otmp1<-LSmultiple(WL,Ti,Ips1)
      SSE0.Iseg<-sum(otmp1$resi[I1:I3]^2)
      FxL<-(SSE0.Iseg-SSEf.Iseg)*(Nseg-3)/SSEf.Iseg
      if(FxL>0) probL<-pf(Fx,1,Nseg-3)
      else probL<-0

      SSEf.Iseg<-sum(resiWU[I1:I3]^2)
      otmp1<-LSmultiple(WU,Ti,Ips1)
      SSE0.Iseg<-sum(otmp1$resi[I1:I3]^2)
      FxU<-(SSE0.Iseg-SSEf.Iseg)*(Nseg-3)/SSEf.Iseg
      if(FxU>0) probU<-pf(Fx,1,Nseg-3)
      else probU<-0

#     else if(Id==1) { # type-1 changepoints
        if(PFx<PFx95l) Idc<-"No  "
        else if(PFx>=PFx95l&PFx<PFx95h) Idc<-"?   "
        else if(PFx>=PFx95h) Idc<-"Yes "
#     }


####################################################
###write "_1Cs.txt"

      cat(paste(sprintf("%1.0f",1)," ",
                sprintf("%-4.4s",Idc),
                sprintf("%10.0f", IY0[Ic])," (",
	        sprintf("%6.4f",probL),"-",
	        sprintf("%6.4f",probU),")",
		sprintf("%6.3f",plev),
	        sprintf("%10.4f",PFx)," (",
	        sprintf("%10.4f",PFx95l),"-",
                sprintf("%10.4f",PFx95h),")\n",sep=""),
		file=ofileIout,
	        append=TRUE)



####################################################
###write "_Ustat.txt"


      cat(paste("PMF : c=", sprintf("%4.0f",Ic),
      		"; (Time ", sprintf("%10.0f",IY0[Ic]),
		"); Type= 1; p=",sprintf("%10.4f",prob),"(",
		sprintf("%6.4f",probL),"-",
		sprintf("%6.4f",probU),")",
		"; PFmax=", sprintf("%10.4f",PFx),
		"; CV95=", sprintf("%10.4f",PFx95),
		"(", sprintf("%10.4f",PFx95l),
		"-", sprintf("%10.4f",PFx95h),
		"); Nseg=", sprintf("%4.0f",Nseg),"\n",sep=""),
		file=ofileSout, append=T)
    }
  }
  if(GUI)
    return(0)
  else{
    file.copy(from=ofileIout,to=ofileMout,overwrite=TRUE)
    #cat("FindU finished successfully...\n")
	InsertMessagesTxt(main.txt.out,paste("FindU finished successfully for",station))
    return(0)
  }
}



