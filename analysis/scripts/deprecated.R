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

# after test_retest.R

subtab <- subset(tab,n_jaw==1 & n_tng==6 & n_lip==2)

# PLOT BIOMARKER SCATTERGRAM
############################

pdf(file.path(graphics_path,"scattergram_biomarker.pdf"))
mean_all <- aggregate(bm ~ participant + tv + repetition, subtab, mean)
sd_all <- aggregate(bm ~ participant + tv + repetition, subtab, sd)
scattergram(mean_all,sd_all)
dev.off()

# BIOMARKER BA PLOT
###################
pdf(file.path(graphics_path,"ba_biomarker.pdf"))
baplot(mean_all)
dev.off()
