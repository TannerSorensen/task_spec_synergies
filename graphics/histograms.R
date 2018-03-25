# REQUIRE A SET OF LIBRARIES
############################
source("require_libraries.R")

# SET GRAPHICS PATH
###################

graphics_path <- file.path(".","histograms")
dir.create(graphics_path, showWarnings = FALSE)

# READ IN DATA-SET
##################

input_path <- file.path("..","mat")

tab <- read.csv(file.path(input_path,"bm_tab.csv"))

# CHOOSE DATA-SET
#################

morphology_dataset <- FALSE

if(morphology_dataset==TRUE){
  tab <- subset(tab,isnan(repetition) & n_jaw==1 & n_tng==6 & n_lip==2)
}else{
  tab <- subset(tab,repetition==1 & n_jaw==1 & n_tng==6 & n_lip==2)
}

participants <- unique(tab$participant)
n_participants <- length(participants)

# PRINT HISTOGRAMS
##################

tv_loc <- c("bilabial place","alveolar place","palatal place","velar place","pharyngeal place")

colrs <- rainbow(n_participants)
spacing <- 2
for(i in seq(1,5)){
  pdf(file.path(graphics_path,paste("histogram_",sub(" ","_",tv_loc[i]),".pdf",sep = "")))
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


