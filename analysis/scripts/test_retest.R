# REQUIRE LIBRARY 'lme4' and 'RColorBrewer'
###########################################

require(lme4)
require(RColorBrewer)
require(rptR)

# DECLARE USER-DEFINED FUNCTIONS
################################

baplot = function(mean_all){
  # BAPLOT - plot Bland-Altman plot of biomarker values in a test-retest evaluation
  # 
  # INPUT: 
  # mean_all - means of all biomarkers (scan 1 and scan 2)
  # sd_all - standard deviations of all biomarkers (scan 1 and scan 2)
  # 
  # FUNCTION OUTPUT: 
  # none
  # 
  # GRAPHIC OUTPUT:
  # scattergram with dots for means and lines for standard deviations. dashed line of equality
  # 
  # Tanner Sorensen
  # Signal Analysis and Interpretation Laboratory
  # University of Southern California
  # Apr. 14, 2017
  
  # biomarker mean
  mean_rep1 <- mean_all[mean_all$repetition==1,4]
  mean_rep2 <- mean_all[mean_all$repetition==2,4]
  
  means <- (mean_rep1+mean_rep2)/2
  diffs <- mean_rep1-mean_rep2
  
  par(pty="s",las=1,cex=2)
  cols<-brewer.pal(n=7,name="Set1")
  cols<-c(cols[1:4],cols[6],cols[7])
  plt_cols<-cols[mean_all[mean_all$repetition==1,2]]
  plot(means,diffs,yaxt='n',xaxt='n',col=plt_cols,pch=16,
       ylim=c(-1,1),xlim=c(0,1),
       xlab="mean",ylab="difference")
  axis(1, at = seq(0,1,0.25), labels=c("0%","","50%","","100%"), las=1)
  rug(x = seq(0,1,0.05), ticksize = -0.01, side = 1)
  axis(2, at = seq(-1,1,0.25), labels=c("-100%","","-50%","","0%","","50%","","100%"), las=1)
  rug(x = seq(-1,1,0.05), ticksize = -0.01, side = 2)
  
  m <- mean(mean_rep1-mean_rep2)
  ub <- m + 1.96*sd(mean_rep1-mean_rep2)
  lb <- m - 1.96*sd(mean_rep1-mean_rep2)
  abline(h=ub,lty=2)
  abline(h=m)
  abline(h=lb,lty=2)
}

scattergram = function(mean_all,sd_all){
  # SCATTERGRAM - plot scattergram of biomarker values in a test-retest evaluation
  # 
  # INPUT: 
  # mean_all - means of all biomarkers (scan 1 and scan 2)
  # sd_all - standard deviations of all biomarkers (scan 1 and scan 2)
  # 
  # FUNCTION OUTPUT: 
  # none
  # 
  # GRAPHIC OUTPUT:
  # scattergram with dots for means and lines for standard deviations. dashed line of equality
  # 
  # Tanner Sorensen
  # Signal Analysis and Interpretation Laboratory
  # University of Southern California
  # Apr. 14, 2017
  
  # biomarker mean
  mean_rep1 <- mean_all[mean_all$repetition==1,4]
  mean_rep2 <- mean_all[mean_all$repetition==2,4]
  
  # biomarker sd
  sd_rep1 <- sd_all[mean_all$repetition==1,4]
  sd_rep2 <- sd_all[mean_all$repetition==2,4]
  
  par(pty="s",las=1,cex=2)
  plot(mean_rep1,mean_rep2,asp=1,xlab = "scan 1 (mm)",ylab = "scan 2 (mm)",xlim=c(0,1),ylim=c(0,1))

  #text(par("usr")[1] - 4, 0, adj = 1, labels = "scan 2 (mm)", xpd = TRUE) 
  for(i in seq(1,length(mean_rep2))){
    lines(rep(mean_rep1[i],2),mean_rep2[i]+c(-sd_rep2[i],sd_rep2[i]))
    lines(mean_rep1[i]+c(-sd_rep1[i],sd_rep1[i]),rep(mean_rep2[i],2))
  }
  
  lines(c(00,25),c(00,25),lty=2)
}

getICC <- function(tab){
  # GETICC - compute the intra-class correlation coefficients of a test-retest evaluation
  # 
  # INPUT: 
  # tab - data frame of all test-retest data
  # 
  # FUNCTION OUTPUT: 
  # ICC - intraclass correlation coefficient
  # 
  # GRAPHIC OUTPUT:
  # none
  # 
  # Tanner Sorensen
  # Signal Analysis and Interpretation Laboratory
  # University of Southern California
  # Apr. 14, 2017
  
  m0 <- rpt(lambda ~ 1 + (1|participant), grname = "participant", data=tab, datatype="Gaussian", nboot=0)
  ICC <- as.double(m0$R)
  return(ICC)
}

# READ IN DATA-SETS
###################

tab <- read.csv(file.path("..","mat","strategies.csv"))
subject_key <- read.csv(file.path("..","mat","artstrat_subjects.csv"))
repeatability_subject_ids <- with(subject_key,subject_id[repeatability_dataset==TRUE & subject_name!="f3"]) # exclude f3 because of poor image quality in scan 2
tab <- subset(tab,participant%in%repeatability_subject_ids) 

# SET GRAPHICS PATH
###################

graphics_path <- file.path("..","graphics")

# BIOMARKER VALUES
##################
tab$lambda <- with(tab,ifelse(tv==1,jaw/(jaw+lip),jaw/(jaw+tng)))

# CONSTANTS
###########
jaw_fac <- c(1,2,3)
tng_fac <- c(4,6,8)
lip_fac <- c(2,3)
tv_loc <- c("bilabial place","alveolar place","palatal place","velar place","pharyngeal place","velopharyngeal port")
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

subtab <- subset(tab,n_jaw==1 & n_tng==6 & n_lip==2)

# PLOT BIOMARKER SCATTERGRAM
############################

pdf(file.path(graphics_path,"scattergram_biomarker.pdf"))
mean_all <- aggregate(lambda ~ participant + tv + repetition, subtab, mean)
sd_all <- aggregate(lambda ~ participant + tv + repetition, subtab, sd)
scattergram(mean_all,sd_all)
dev.off()

# BIOMARKER BA PLOT
###################
pdf(file.path(graphics_path,"ba_biomarker.pdf"))
baplot(mean_all)
dev.off()
