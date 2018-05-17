get_err_plot <- function(jaw_fac,tng_fac,lip_fac){
  # REQUIRE A SET OF LIBRARIES
  ############################
  source(file.path("..","..","paper","graphics","require_libraries.R"))
  
  ########################
  # USER-DEFINED FUNCTIONS
  ########################
  
  source(file.path("..","..","paper","graphics","declare_user_defined_functions.R"))
  
  #################
  # CHOOSE DATA-SET
  #################
  
  morphology_dataset <- TRUE
  
  ###################
  # READ IN DATA-SETS
  ###################
  
  input_path <- file.path("..","..","analysis","mat")
  
  suffix <- paste("_jaw",jaw_fac,"_tng",tng_fac,"_lip",lip_fac,"_vel1_lar2",sep="")
  
  tab <- read.csv(file.path(input_path,paste("err_tab",suffix,".csv",sep="")))
  stds <- read.csv(file.path(input_path,paste("stds_tab",suffix,".csv",sep="")))
  
  if(morphology_dataset==TRUE){
    tab <- subset(tab,is.nan(repetition))
    stds <- subset(stds,is.nan(repetition))
    spat_res <- 2.8
  }else{
    tab <- subset(tab,repetition==1)
    stds <- subset(stds,repetition==1)
    spat_res <- 2.4
  }
  
  #####################
  # CONVERT TO MM UNITS
  #####################
  
  numeric_cols <- c("bilabial","alveolar","palatal","velar","pharyngeal","bilabial_d","alveolar_d","palatal_d","velar_d","pharyngeal_d")
  stds[,numeric_cols] <- spat_res*stds[,numeric_cols]
  tab[,numeric_cols] <- spat_res*tab[,numeric_cols]
  
  ###################
  # SET GRAPHICS PATH
  ###################
  
  graphics_path <- file.path(".","cv_errors")
  dir.create(graphics_path, showWarnings = FALSE)
  
  ############
  # LEGEND
  ############
  
  library(RColorBrewer)
  pdf(file.path(graphics_path,"err_legend.pdf"), width=8, height=8, bg="white")
  cols<-brewer.pal(n=7,name="Set1")
  cols<-c(cols[1:4],cols[7])
  plot.new()
  legend(0,1,c('bilabial place','alveolar place','palatal place','velar place','pharyngeal place'),cols)
  dev.off()
  
  ############
  # bilabial
  ############
  col_idx <- 1
  
  # direct kinematics error plots
  plt_tab <- aggregate(bilabial ~ participant + f, tab, function(x){median(abs(x))})
  plot_means(plt_tab,stds[,c("participant","bilabial")],col_idx,TRUE,"bilabial place",graphics_path,suffix)
  
  # differential kinematics error plots
  plt_tab <- aggregate(bilabial_d ~ participant + f, tab, function(x){median(abs(x))})
  plot_means(plt_tab,stds[,c("participant","bilabial_d")],col_idx,TRUE,"bilabial place",graphics_path,suffix)
  
  ############
  # alveolar
  ############
  col_idx <- 2
  
  # direct kinematics error plots
  plt_tab <- aggregate(alveolar ~ participant + f, tab, function(x){median(abs(x))})
  plot_means(plt_tab,stds[,c("participant","alveolar")],col_idx,FALSE,"alveolar place",graphics_path,suffix)
  
  # differential kinematics error plots
  plt_tab <- aggregate(alveolar_d ~ participant + f, tab, function(x){median(abs(x))})
  plot_means(plt_tab,stds[,c("participant","alveolar_d")],col_idx,FALSE,"alveolar place",graphics_path,suffix)
  
  ############
  # palatal
  ############
  col_idx <- 3
  
  # direct kinematics error plots
  plt_tab <- aggregate(palatal ~ participant + f, tab, function(x){median(abs(x))})
  plot_means(plt_tab,stds[,c("participant","palatal")],col_idx,FALSE,"palatal place",graphics_path,suffix)
  
  # differential kinematics error plots
  plt_tab <- aggregate(palatal_d ~ participant + f, tab, function(x){median(abs(x))})
  plot_means(plt_tab,stds[,c("participant","palatal_d")],col_idx,FALSE,"palatal place",graphics_path,suffix)
  
  
  ############
  # velar
  ############
  col_idx <- 4
  
  # direct kinematics error plots
  plt_tab <- aggregate(velar ~ participant + f, tab, function(x){median(abs(x))})
  plot_means(plt_tab,stds[,c("participant","velar")],col_idx,FALSE,"velar place",graphics_path,suffix)
  
  # differential kinematics error plots
  plt_tab <- aggregate(velar_d ~ participant + f, tab, function(x){median(abs(x))})
  plot_means(plt_tab,stds[,c("participant","velar_d")],col_idx,FALSE,"velar place",graphics_path,suffix)
  
  
  ############
  # pharyngeal
  ############
  col_idx <- 6
  
  # direct kinematics error plots
  plt_tab <- aggregate(pharyngeal ~ participant + f, tab, function(x){median(abs(x))})
  plot_means(plt_tab,stds[,c("participant","pharyngeal")],col_idx,FALSE,"pharyngeal place",graphics_path,suffix)
  
  # differential kinematics error plots
  plt_tab <- aggregate(pharyngeal_d ~ participant + f, tab, function(x){median(abs(x))})
  plot_means(plt_tab,stds[,c("participant","pharyngeal_d")],col_idx,FALSE,"pharyngeal place",graphics_path,suffix)
}


# obtain the error plots for different numbers of factors
for(jaw_fac in c(1,2,3)){
  for(tng_fac in c(4,6,8)){
    lip_fac <- 2
    get_err_plot(jaw_fac,tng_fac,lip_fac)
  }
  for(lip_fac in c(2,3)){
    tng_fac <- 4
    get_err_plot(jaw_fac,tng_fac,lip_fac)
  }
}
