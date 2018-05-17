plot_histograms <- function(jaw_fac,tng_fac,lip_fac,f_val,morphology_dataset){
  # REQUIRE A SET OF LIBRARIES
  ############################
  source("require_libraries.R")
  
  # SET GRAPHICS PATH
  ###################
  
  graphics_path <- file.path(".","histograms")
  dir.create(graphics_path, showWarnings = FALSE)
  
  # READ IN DATA-SET
  ##################
  
  input_path <- file.path("..","..","analysis","mat")
  
  tab <- read.csv(file.path(input_path,paste("bm_tab_f",f_val,".csv",sep = "")))
  
  # CHOOSE DATA-SET
  #################
  
  if(morphology_dataset==TRUE){
    tab <- subset(tab,is.nan(repetition) & n_jaw==1 & n_tng==6 & n_lip==2)
  }else{
    tab <- subset(tab,repetition==1 & n_jaw==1 & n_tng==6 & n_lip==2)
  }
  
  participants <- unique(tab$participant)
  n_participants <- length(participants)
  
  # PRINT HISTOGRAMS
  ##################
  
  tv_loc <- c("bilabial place","alveolar place","palatal place","velar place","pharyngeal place")
  
  suffix <- paste("_jaw",jaw_fac,"_tng",tng_fac,"_lip",lip_fac,"_f",f_val,sep="")
  
  colrs <- rainbow(n_participants)
  spacing <- 2
  for(i in seq(1,5)){
    pdf(file.path(graphics_path,paste("histogram_",sub(" ","_",tv_loc[i]),suffix,".pdf",sep = "")))
    par(mar=c(5,6,4,1)+.1)
    with(tab,hist(bm[tv==i],main=tv_loc[i],
                     yaxt="n",ylab="frequency",ylim=c(-n_participants*spacing,30),
                     xaxt="n",xlab="percent jaw contribution",xlim=c(0,1),
                     cex.axis=2,cex.lab=2,cex.main=2))
    yul <- par("usr")[4] - par("usr")[4] %% 10
    axis(1, at=seq(0,1,length.out=5), labels=seq(0,100,length.out=5), cex.axis=2)
    axis(2, at=seq(0,yul,length.out=(yul+1)/10),cex.axis=2)
    k <- 1
    for(j in seq(1,n_participants)){
      idx <- with(tab, tv==i & participant==participants[j])
      with(tab,points(bm[idx],rep(-k*spacing,sum(idx)),col="#000000",bg=colrs[k],pch=21,cex=2))
      k <- k+1
    }
    dev.off()
  }
}

morphology_dataset <- FALSE

for(f_val in seq(from = 20, to = 90, by = 10)){
  for(jaw_fac in c(1,2,3)){
    lip_fac <- 2
    for(tng_fac in c(4,6,8)){
      plot_histograms(jaw_fac,tng_fac,lip_fac,f_val,morphology_dataset)
    }
    tng_fac <- 4
    plot_histograms(jaw_fac,tng_fac,lip_fac,f_val,morphology_dataset)
  }
}
