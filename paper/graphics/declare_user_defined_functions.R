plot_means <- function(plt_tab,stds,col_idx,xlab_flag,titl,graphics_path){
  require(RColorBrewer)
  cols<-brewer.pal(n=7,name="Set1")
  cols<-c(cols[1:4],cols[6],cols[7])
  
  x_val_idx <- colnames(plt_tab)[2]
  y_val_idx <- colnames(plt_tab)[3]
  pdf(file.path(graphics_path,paste("err_",y_val_idx,".pdf",sep="")), width=4, height=4, bg="white")
  
  if(xlab_flag==TRUE){
    ylbl <- "RMSE (mm)"
  }else{
    ylbl <- ""
  }
  
  yub <- 2.4
  for(i in unique(plt_tab$participant)){
    row_idx <- plt_tab[,1]==i
    if(i==unique(plt_tab$participant)[1]){
      plot(plt_tab[row_idx,x_val_idx],plt_tab[row_idx,y_val_idx],
           type="o",col=cols[col_idx],pch=19,cex.lab=1.5,
           ylim=c(0,yub),xlim=c(0,1),
           xaxt='n',yaxt='n',
           xlab = "neighborood size",
           ylab = ylbl,
           main = titl)
    }else{
      lines(plt_tab[row_idx,x_val_idx],plt_tab[row_idx,y_val_idx],type="o",col=cols[col_idx],pch=19)
    }
  }
  axis(1, at=seq(0,1,0.2), labels=paste(seq(0,100,20),"%",sep=""), cex.axis=1)
  rug(x = seq(0.05,0.95,0.05), ticksize = -0.01, side = 1)
  axis(2, at=seq(0,yub,0.2),cex.axis=1)
  rug(x = seq(0,yub,0.05), ticksize = -0.01, side = 2)
  rug(x = sort(stds[,2]), ticksize = 0.05, side = 4)
  dev.off()
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
  
  m0 <- rpt(bm ~ 1 + (1|participant), grname = "participant", data=tab, datatype="Gaussian", nboot=0)
  ICC <- as.double(m0$R)
  return(ICC)
}


getICCrating <- function(ICC){
  if(ICC <= 0.3){
    ICCrating <- "poor"
  }else if(ICC <= 0.5){
    ICCrating <- "weak"
  }else if(ICC <= 0.7){
    ICCrating <- "moderate"
  }else if(ICC <= 0.9){
    ICCrating <- "strong"
  }else if(ICC <= 1){
    ICCrating <- "very strong"
  }
  return(ICCrating)
}


get_stats <- function(n_jaw,n_tng,n_lip,f_val,morphology_dataset){
  # READ IN DATA-SET
  ##################
  
  tab <- read.csv(file.path("..","..","analysis","mat",paste("bm_tab_f",f_val,".csv",sep="")))
  if(morphology_dataset==TRUE){
    tab <- subset(tab,is.nan(repetition) & n_jaw==jaw_fac & n_tng==tng_fac & n_lip==lip_fac)
  }else{
    tab <- subset(tab,repetition==1 & n_jaw==jaw_fac & n_tng==tng_fac & n_lip==lip_fac)
  }
  
  # PERFORM STATISTICAL TEST
  ##########################
  
  tab$tv <- factor(tab$tv)
  tab$participant <- factor(tab$participant)
  
  # velar as baseline
  contrasts(tab$tv) <- contr.treatment(5, base = 4)
  m_velar <- lmer(bm ~ 1 + tv + (1 + tv | participant), tab, REML=TRUE)
  stat_test <- summary(glht(m_velar,linfct=c("tv1 = 0",
                                             "tv2 = 0",
                                             "tv3 = 0",
                                             "tv1 - tv5 = 0",
                                             "tv2 - tv5 = 0",
                                             "tv3 - tv5 = 0")))
  
  b <- signif(100*stat_test$test$coefficients,2)
  z <- signif(stat_test$test$tstat,2)
  p <- signif(as.numeric(stat_test$test$pvalues),2)
  
  return(list(b,z,p))
}
