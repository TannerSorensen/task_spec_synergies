# REQUIRE A SET OF LIBRARIES
############################
source("require_libraries.R")

# DECLARE USER-DEFINED FUNCTIONS
################################

source("declare_user_defined_functions.R")

# READ IN DATA-SETS
###################

input_path <- file.path("..","..","analysis","mat")

tab <- read.csv(file.path(input_path,"bm_tab_f70.csv"))

# CHOOSE REPEATABILITY DATASET
# (NOT MORPHOLOGY DATASET)
##############################

tab <- subset(tab,!is.nan(repetition))

# SET GRAPHICS PATH
###################

graphics_path <- file.path("icc")
dir.create(graphics_path, showWarnings = FALSE)

# CONSTANTS
###########
jaw_fac <- c(1,2,3)
tng_fac <- c(4,6,8)
lip_fac <- c(2,3)
tv_loc <- c("bilabial place","alveolar place","palatal place","velar place","pharyngeal place")
font_scale <- 3
cols<-brewer.pal(n=3,name="Set1")

# PLOT ICC AT BILABIAL PLACE
############################
tv_loc_idx <- 1
icc <- matrix(nrow=length(lip_fac),ncol=length(jaw_fac))
for(j in 1:length(jaw_fac)){
  for(k in 1:length(lip_fac)){
    icc[k,j] <- getICC(subset(tab,n_jaw==jaw_fac[j] & n_tng==4 & n_lip==lip_fac[k] & tv==tv_loc_idx))
  }
}
pdf(file.path(graphics_path,paste(paste("icc",gsub(" ","_",tv_loc[tv_loc_idx]),sep="_"),".pdf",sep="")))
op <- par(mar = c(5,9,4,2) + 0.1)
matplot(lip_fac,icc, 
        col=cols, type="b", pch=1, lty=1, lwd=2, axes=FALSE, las=1, cex=4,
        ylim=c(0,1), ylab="ICC", xlim=(range(lip_fac)+c(-0.5,0.5)), xlab="lip factors", cex.lab=font_scale)
axis(side=1, at=lip_fac, labels=c("2","3"), col.ticks=1, col=NA, cex.axis=font_scale)
axis(side=2, at=seq(0,1,by=0.25), labels=c("0","0.25","0.5","0.75","1"), col.ticks=1, las=1, cex.axis=font_scale, cex.lab=font_scale, line=-3)
title(tv_loc[tv_loc_idx], cex.main=font_scale)
dev.off()

# PLOT ICC AT LINGUAL PLACES
############################
for(tv_loc_idx in seq(2,5)){
  icc <- matrix(nrow=length(tng_fac),ncol=length(jaw_fac))
  for(j in 1:length(jaw_fac)){
    for(k in 1:length(tng_fac)){
      icc[k,j] <- getICC(subset(tab,n_jaw==jaw_fac[j] & n_tng==tng_fac[k] & n_lip==2 & tv==tv_loc_idx))
    }
  }
  titl <- tv_loc[tv_loc_idx]
  pdf(file.path(graphics_path,paste(paste("icc",gsub(" ","_",titl),sep="_"),".pdf",sep="")))
  op <- par(mar = c(5,8,4,2) + 0.1)
  matplot(tng_fac,icc, 
          col=cols, type="b", pch=1, lty=1, lwd=2, axes=FALSE, las=1, cex=4,
          ylim=c(0,1), ylab="", xlim=(range(tng_fac)+c(-0.5,0.5)), xlab="tongue factors", cex.lab=font_scale)
  axis(side=1, at=tng_fac, labels=c("4","6","8"), 
       col.ticks=1, col=NA, cex.axis=font_scale)
  axis(side=2, at=seq(0,1,by=0.25), labels=c("0","0.25","0.5","0.75","1"), 
       col.ticks=1, las=1, cex.axis=font_scale, cex.lab=font_scale)
  title(titl,cex.main=font_scale)
  dev.off()
}

pdf(file.path(graphics_path,"legend.pdf"))
plot.new()
legend("center", legend = c("1 jaw factor","2 jaw factors","3 jaw factors"), col=cols, pch=1, lty=1, lwd=2)
dev.off()