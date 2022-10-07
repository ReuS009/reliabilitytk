# Lognormal Probability Plot
# Developed by Dr. Reuel Smith, 2021-2022

probplot.logn <- function(data,pp,xlabel1) {
  # Check if X is there
  if(missing(xlabel1)) {
    xlabel1<-"X"
  }
  # =====================================================
  # NEW CODE BLOCK - REPEAT IN ALL PLOT FUNCTIONS (Begin)
  # =====================================================
  # =====================================================

  dcount<-checkdatacount(checkstress(data))
  # Error message to check if there is any plots for a life distribution estimate
  if(sum(dcount[[1]])==0){
    stop('Please check that there are at least two failure data that occur in the same stress level.')
  }

  # Check for whether the curve vector and censor vector are the same or not.  If
  # they are identical it means all relevant curves have failure data.  If not
  # then it is an indicator of some data not having curves and therefore must be
  # held over for further analysis.
  if(identical(dcount[[1]],dcount[[2]])){
    databystress<-checkstress(data)
    singledat<-NULL
  } else{
    databystress<-checkstress(data)[which(dcount[[1]] == 1 & dcount[[2]] == 1)]
    singledat<-checkstress(data)[which(!dcount[[1]] == 1 & dcount[[2]] == 1)]
  }

  # =====================================================
  # =====================================================
  # NEW CODE BLOCK - REPEAT IN ALL PLOT FUNCTIONS (End)
  # =====================================================


  # Initialize Percent Failure ticks
  Pticks1 <- c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,c(1:10),10*c(2:9),95,99,99.9)
  Pticks <- qnorm(Pticks1/100,mean=0,sd=1)
  Pticks1label <- c(0.1,0.2,0.3,"",0.5,"","","","",1,2,3,"",5,"","","","",10*c(1:9),95,99,99.9)
  fcB <- qnorm(c(.001,0.999),mean=0,sd=1)

  if (!is.null(dim(databystress))){
    # Single Stress data
    ixirc<-sort.xircdata(data)
    xiRFblock<-plotposit.select(ixirc[[2]],ixirc[[3]],pp)
    # Data pull
    XB<-xiRFblock[,1]
    FB <- qnorm(xiRFblock[,2],mean=0,sd=1)
    ttfc <- probplotparam.logn(xiRFblock[,1],xiRFblock[,2])
    ttfcrange <- ttfc[[1]]
    params<-ttfc[[3]]
    outputpp<-list(ttfc[[3]],ttfc[[4]])
  } else {
    ixirc_list<- vector(mode = "list", length = length(databystress))
    xiRFblock_list<- vector(mode = "list", length = length(databystress))
    XB_list<- vector(mode = "list", length = length(databystress))
    FB_list<- vector(mode = "list", length = length(databystress))
    ttfc_list<- vector(mode = "list", length = length(databystress))

    #UPDATE
    outputpp <- vector(mode = "list", length = 3*length(databystress)+1)
    ttfcrange<-c(1)
    XBfull<-c(1)
    FBfull<-c(1)
    # Multi-stress data
    for(i in 1:length(databystress)){
      ixirc_list[[i]]<-sort.xircdata(databystress[[i]])
      xiRFblock_list[[i]]<-plotposit.select(ixirc_list[[i]][[2]],ixirc_list[[i]][[3]],pp)
      # Data pull
      XB_list[[i]]<-xiRFblock_list[[i]][,1]
      FB_list[[i]] <- qnorm(xiRFblock_list[[i]][,2],mean=0,sd=1)
      ttfc_list[[i]]<-probplotparam.logn(xiRFblock_list[[i]][,1],xiRFblock_list[[i]][,2])
      outputpp[[i*3-2]]<-databystress[[i]][1,3:length(databystress[[i]][1,])]
      outputpp[[i*3-1]]<-ttfc_list[[i]][[3]]
      outputpp[[i*3]]<-ttfc_list[[i]][[4]]
      XBfull<-c(XBfull,XB_list[[i]])
      FBfull<-c(FBfull,FB_list[[i]])
      ttfcrange<-c(ttfcrange,ttfc_list[[i]][[1]])
    }
    #NEW LINE
    outputpp[[3*length(databystress)+1]]<-singledat
    ttfcrange<-ttfcrange[2:length(ttfcrange)]
    XBfull<-XBfull[2:length(XBfull)]
    FBfull<-FBfull[2:length(FBfull)]
  }

  # Computes the upper and lower bound for the TTF axis in terms of log-time
  signs1 <- c(floor(log10(min(ttfcrange))):ceiling(log10(max(ttfcrange))))
  logtimes1 <- 10^signs1
  Pticks1X <- c(1:(9*length(logtimes1)-8))
  Pticks1X[1] <- logtimes1[1]
  Pticks1Xlabel <- Pticks1X

  for(i2 in 1:(length(signs1)-1)){
    Pticks1X[(9*i2-7):(9*(i2+1)-8)] <- logtimes1[i2]*c(2:10)
    Pticks1Xlabel[(9*i2-7):(9*(i2+1)-8)] <- c("","","","","","","","",logtimes1[i2+1])
  }

  # Plot
  if (!is.null(dim(databystress))){
    plot(XB, FB, log="x", col="blue",
         xlab=xlabel1, ylab="Percent Failure", pch=16,
         xlim=c(10^min(signs1), 10^max(signs1)), ylim=c(min(fcB), max(fcB)), axes=FALSE)
    lines(ttfc[[1]], ttfc[[2]], col="blue")
  } else {
    plot(XBfull, FBfull, log="x", col="blue",
         xlab=xlabel1, ylab="Percent Failure", pch=16,
         xlim=c(10^min(signs1), 10^max(signs1)), ylim=c(min(fcB), max(fcB)), axes=FALSE)
    for(i in 1:length(databystress)){
      lines(ttfc_list[[i]][[1]], ttfc_list[[i]][[2]], col="blue")
    }
  }
  axis(1, at=Pticks1X,labels=Pticks1Xlabel, las=2, cex.axis=0.7)
  axis(2, at=Pticks,labels=Pticks1label, las=2, cex.axis=0.7)

  #Add horizontal and vertical grid
  abline(h = Pticks, lty = 2, col = "grey")
  abline(v = Pticks1X,  lty = 2, col = "grey")

  legend(10^signs1[1], qnorm(0.99,mean=0,sd=1), legend=c("Data", "Lognormal best fit line"),
         col=c("blue", "blue"), pch=c(16,-1), lty=c(0,1), cex=0.8,
         text.font=4, bg='white')
  return(outputpp)
}