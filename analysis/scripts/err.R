########################
# USER-DEFINED FUNCTIONS
########################

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
      lines(plt_tab[row_idx,x_val_idx],plt_tab[row_idx,y_val_idx]/stds[stds$participant==i,2],type="o",col=cols[col_idx],pch=19)
    }
  }
  axis(1, at=seq(0,1,0.2), labels=paste(seq(0,100,20),"%",sep=""), cex.axis=1)
  rug(x = seq(0.05,0.95,0.05), ticksize = -0.01, side = 1)
  axis(2, at=seq(0,yub,0.2),cex.axis=1)
  rug(x = seq(0,yub,0.05), ticksize = -0.01, side = 2)
  rug(x = sort(stds[,2]), ticksize = 0.05, side = 4)
  dev.off()
}

#################
# CHOOSE DATA-SET
#################

morphology_dataset <- FALSE

###################
# READ IN DATA-SETS
###################

input_path <- file.path("..","mat")

subject_key <- read.csv(file.path(input_path,"err_subjects.csv"))
if(morphology_dataset==TRUE){
  subject_ids <- with(subject_key,subject_id[repeatability_dataset==FALSE])
}else{
  subject_ids <- with(subject_key,subject_id[repeatability_dataset==TRUE])
}

tab <- read.csv(file.path(input_path,"err.csv"))
tab <- subset(tab,participant%in%subject_ids)

stds <- read.csv(file.path(input_path,"stds.csv"))
stds <- subset(stds,participant%in%subject_ids)

#####################
# CONVERT TO MM UNITS
#####################

spat_res <- 2.4
stds[,2:ncol(stds)] <- spat_res*stds[,2:ncol(stds)]
tab[,4:ncol(tab)] <- spat_res*tab[,4:ncol(tab)]

###################
# SET GRAPHICS PATH
###################

graphics_path <- file.path("..","graphics")

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
plt_tab <- aggregate(bilabial ~ participant + f_param, tab, function(x){median(abs(x))})
plot_means(plt_tab,stds[,c("participant","bilabial")],col_idx,TRUE,"bilabial place",graphics_path)

# differential kinematics error plots
plt_tab <- aggregate(bilabial_d ~ participant + f_param, tab, function(x){median(abs(x))})
plot_means(plt_tab,stds[,c("participant","bilabial_d")],col_idx,TRUE,"bilabial place",graphics_path)

############
# alveolar
############
col_idx <- 2

# direct kinematics error plots
plt_tab <- aggregate(alveolar ~ participant + f_param, tab, function(x){median(abs(x))})
plot_means(plt_tab,stds[,c("participant","alveolar")],col_idx,FALSE,"alveolar place",graphics_path)

# differential kinematics error plots
plt_tab <- aggregate(alveolar_d ~ participant + f_param, tab, function(x){median(abs(x))})
plot_means(plt_tab,stds[,c("participant","alveolar_d")],col_idx,FALSE,"alveolar place",graphics_path)

############
# palatal
############
col_idx <- 3

# direct kinematics error plots
plt_tab <- aggregate(palatal ~ participant + f_param, tab, function(x){median(abs(x))})
plot_means(plt_tab,stds[,c("participant","palatal")],col_idx,FALSE,"palatal place",graphics_path)

# differential kinematics error plots
plt_tab <- aggregate(palatal_d ~ participant + f_param, tab, function(x){median(abs(x))})
plot_means(plt_tab,stds[,c("participant","palatal_d")],col_idx,FALSE,"palatal place",graphics_path)


############
# velar
############
col_idx <- 4

# direct kinematics error plots
plt_tab <- aggregate(velar ~ participant + f_param, tab, function(x){median(abs(x))})
plot_means(plt_tab,stds[,c("participant","velar")],col_idx,FALSE,"velar place",graphics_path)

# differential kinematics error plots
plt_tab <- aggregate(velar_d ~ participant + f_param, tab, function(x){median(abs(x))})
plot_means(plt_tab,stds[,c("participant","velar_d")],col_idx,FALSE,"velar place",graphics_path)


############
# pharyngeal
############
col_idx <- 6

# direct kinematics error plots
plt_tab <- aggregate(pharyngeal ~ participant + f_param, tab, function(x){median(abs(x))})
plot_means(plt_tab,stds[,c("participant","pharyngeal")],col_idx,FALSE,"pharyngeal place",graphics_path)

# differential kinematics error plots
plt_tab <- aggregate(pharyngeal_d ~ participant + f_param, tab, function(x){median(abs(x))})
plot_means(plt_tab,stds[,c("participant","pharyngeal_d")],col_idx,FALSE,"pharyngeal place",graphics_path)

