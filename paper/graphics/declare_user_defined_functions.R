plot_percentile_range <- function(pctl_tab,stds,col_idx,xlab_flag,titl,graphics_path,filename_suffix){
  require(RColorBrewer)
  cols<-brewer.pal(n=7,name="Set1")
  cols<-c(cols[1:4],cols[6],cols[7])
  
  plot.new()
  
  if(xlab_flag==TRUE){
    ylbl <- "error (mm)"
  }else{
    ylbl <- ""
  }
  
  yub <- 2.4
  
  df <- data.frame(intvl=pctl_tab[,1], 
                   med=pctl_tab[,2][,2],
                   lb=pctl_tab[,2][,3],
                   ub=pctl_tab[,2][,1])
  ggplot(data=df, aes(x=intvl, y=med)) + geom_point() + geom_line() + 
    geom_ribbon(aes(ymin=lb, ymax=ub), linetype=2, alpha=0.1) +
    theme_classic(base_size = 20) +
    labs(x="neighborhood size",
         y=ylbl,
         title=titl)
  
  axis(1, at=seq(0,1,0.2), labels=paste(seq(0,100,20),"%",sep=""), cex.axis=1)
  rug(x = seq(0.05,0.95,0.05), ticksize = -0.01, side = 1)
  axis(2, at=seq(0,yub,0.2),cex.axis=1)
  rug(x = seq(0,yub,0.05), ticksize = -0.01, side = 2)
  rug(x = mean(stds[,2]), ticksize = 0.1, side = 4)
  
  ggsave(file.path(graphics_path,paste("err_",paste(sub(" ","_",titl),filename_suffix,sep = ""),".pdf",sep="")), plot = last_plot(), device = NULL, path = NULL,
         scale = 1, width = 4, height = 4, units = "in",
         dpi = 600, limitsize = TRUE)
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
