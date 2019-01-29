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

tab <- tab[!is.nan(tab$repetition),]

# CONSIDER ONLY ONE FACTOR ANALYSIS PARAMETERIZATION
####################################################

tab <- tab[tab$n_jaw==1 & tab$n_tng==4 & tab$n_lip==2,]
tab$participant <- factor(tab$participant)

# MAKE TASK VARIABLE A FACTOR
#############################

tab$tv <- factor(tab$tv, levels = c(1, 2, 3, 4, 5), labels = c("bilabial","coronal","palatal","velar","pharyngeal"))
unique_tv <- unique(tab$tv)
unique_participant <- unique(tab$participant)

# SET GRAPHICS PATH
###################

graphics_path <- file.path("consistency")
dir.create(graphics_path, showWarnings = FALSE)

# SET GRAPHICS PARAMETERS
#########################

set.seed(001)
jit <- runif(n=length(unique(tab$participant)), min=-0.075,max=0.075)
participant_col_vec = brewer.pal(length(unique(tab$participant)), "Set2")
tv_col_vec = brewer.pal(n=7,name="Set1")
tv_col_vec <- c(tv_col_vec[1:4],tv_col_vec[7])

# # GGPUBR BY PARTICIPANT
# #######################
# 
# library(ggpubr)
# my_comparisons <- combn(as.character(unique_tv), 2, FUN = NULL, simplify = FALSE)
# compare_means(bm ~ tv, data = tab, method = "wilcox.test", group.by = "participant", p.adjust.method = "bonferroni")
# p <- ggboxplot(tab, x = "tv", y = "bm",
#                color = "tv", palette = "jco",
#                ylim = c(0,7), 
#                add = "jitter", facet.by = "participant", nrow=2, ncol=4, short.panel.labs = FALSE,
#                legend.title="place of articulation",
#                xlab="")
# p + stat_compare_means(comparisons = my_comparisons, label =  "p.signif", label.y = seq(1.5,10,0.5)) + 
#   rotate_x_text()

# PIRATEPLOT BY PARTICIPANT
###########################

# containers for statistics
meanvar_df <- data.frame(participant = numeric(0), tv1 = numeric(0), tv2 = numeric(0), 
                         mean_stat = numeric(0), mean_p = numeric(0), var_stat = numeric(0), var_p = numeric(0))
mean_idx <- array(FALSE, c(length(unique_participant), length(unique_tv), length(unique_tv)))
var_idx <- array(FALSE, c(length(unique_participant), length(unique_tv), length(unique_tv)))

# set comparisons
comparisons <- combn(as.character(unique_tv), 2, FUN = NULL, simplify = FALSE)

# significance threshold
# (note: the factor 2 comes from the fact that we are making two tests in each cell:
#  Mann-Whitney U Test; Fligner-Killeen Test;
#  The factor length(unique_participant) comes from the number of participants, since
#  each participant is tested separately;
#  The factor (length(unique_tv)^2 - length(unique_tv))/2 is the number of unique combinations 
#  of task variables, irrespective of ordering and with only distinct elements)
alpha <- 0.05/(2 * length(unique_participant) * (length(unique_tv)^2 - length(unique_tv))/2)

# initialize graphics parameters
pdf(file.path(graphics_path,paste("consistency_by_participant.pdf",sep = "")))
par(mfrow=c(2,length(unique_participant)/2), oma=c(2,4,0,0), mar=c(10,0,2,0), xpd = TRUE)
for (ii in seq(1,length(unique_participant))){
  # subset participant data
  subtab <- subset(tab,participant==unique_participant[ii])
  
  # main plotting function
  titl <- paste(substr(unique_participant[ii],1,1), (ii-1) %% 4 + 1, sep="")
  pirateplot(bm~tv, data = subtab, inf.method = 'ci', inf.disp = 'line',
             ylim = c(0,1), xaxt= "n", yaxt="n", xlab="", ylab="",
             pal=tv_col_vec, theme = 3,
             main=titl)
  
  # place of articulation label
  xlocs <- seq(1,5)
  mtext(side=1, text=levels(subtab$tv), at=xlocs, line=0, cex=0.5)
  
  # biomarker label
  if (ii %in% c(1,5)){
    ylocs <- seq(0,1,0.1)
    mtext(2, text=paste(100*ylocs,"%",sep=""), at=ylocs, line=1, las=1, cex=0.5)
    mtext(2, text="biomarker", at=mean(ylocs), line=3, las=0, cex=0.75)
  }
  
  # plot lines
  mann_whitney_p <- sapply(comparisons, FUN=function(comp){
    with(subtab, wilcox.test(bm[tv==comp[1]], bm[tv==comp[2]]), subset=tv %in% comp)$p.value})
  ell <- 2
  baseline <- -0.2
  ell <- 2
  for (k in seq(1,length(comparisons))){
    if (mann_whitney_p[k]  < alpha){
      x_a <- match(comparisons[[k]][1], unique_tv)
      x_b <- match(comparisons[[k]][2], unique_tv)
      if (x_b-x_a==1){
        yloc <- baseline - 0.025
        lines(c(x_a+0.1,x_b-0.1), rep(yloc, 2),lty=1)
      }else{
        yloc <- baseline - (ell)*0.025
        lines(c(x_a+0.1,x_b-0.1), rep(yloc, 2),lty=1)
        ell = ell+1
      }
    }
  }
  if (ii==1){
    midline_y <- baseline - (ell)*0.025 -0.05
  }
  if (ii %in% c(1,5)){
    # separate the line blocks
    lines(c(0.5,6),rep(midline_y,2), lty=2)
    # title the line blocks
    text(x=0.4,y=7*midline_y/12, labels="Mann-Whitney", srt=90, adj=c(0.5,0.5), cex=0.6)
    text(x=0.4,y=1.5*midline_y, labels="Fligner-Killeen", srt=90, adj=c(0.5,0.5), cex=0.6)
  }else{
    # separate the line blocks
    lines(c(0,6),rep(midline_y,2), lty=2)
  }
  
  fligner_p <- sapply(comparisons, FUN=function(comp){
    with(subset(subtab,tv %in% comp), fligner.test(x=bm, g=tv))$p.value})
  baseline <- baseline - (ell)*0.025 - 0.1
  ell <- 2
  for (k in seq(1,length(comparisons))){
    if (fligner_p[k]  < alpha){
      x_a <- match(comparisons[[k]][1], unique_tv)
      x_b <- match(comparisons[[k]][2], unique_tv)
      if (x_b-x_a==1){
        yloc <- baseline - 0.025
        lines(c(x_a+0.1,x_b-0.1), rep(yloc, 2),lty=1)
      }else{
        yloc <- baseline - (ell)*0.025
        lines(c(x_a+0.1,x_b-0.1), rep(yloc, 2),lty=1)
        ell = ell+1
      }
    }
  }
}
dev.off()

# PIRATEPLOT BY TV
##################

# containers for statistics
meanvar_df <- data.frame(participant = numeric(0), tv1 = numeric(0), tv2 = numeric(0), 
                         mean_stat = numeric(0), mean_p = numeric(0), var_stat = numeric(0), var_p = numeric(0))
mean_idx <- array(FALSE, c(length(unique_participant), length(unique_tv), length(unique_tv)))
var_idx <- array(FALSE, c(length(unique_participant), length(unique_tv), length(unique_tv)))

# significance threshold
# (note: the factor 2 comes from the fact that we are making two tests in each cell:
#  Mann-Whitney U Test; Fligner-Killeen Test;
#  The factor length(unique_participant) comes from the number of participants, since
#  each participant is tested separately;
#  The factor (length(unique_tv)^2 - length(unique_tv))/2 is the number of unique combinations 
#  of task variables, irrespective of ordering and with only distinct elements)
alpha <- 0.05/(2 * length(unique_participant) * (length(unique_tv)^2 - length(unique_tv))/2)

# initialize graphics parameters
pdf(file.path(graphics_path,paste("consistency.pdf",sep = "")))
par(mfrow=rep(length(unique_tv), 2), mar=c(0,0,2,0), cex=0.25, cex.axis=1, cex.lab=1, cex.main=2)

for (ii in seq(1,length(unique_tv))){
  for (jj in seq(1,length(unique_tv))){
    subtab <- subset(tab,tv==unique_tv[ii] | tv==unique_tv[jj])
    subtab$participant <- factor(subtab$participant, levels=unique_participant, 
                                 labels=c("1","2","3","4","5","6","7","8"))
    
    if (ii!=jj){
      # Test for Difference in Mean
      mean_stat <- sapply(unique_participant, FUN=function(p){
        with(subset(tab,participant==p), wilcox.test(bm[tv==unique_tv[ii]], bm[tv==unique_tv[jj]]))$statistic})
      mean_p <- sapply(unique_participant, FUN=function(p){
        with(subset(tab,participant==p), wilcox.test(bm[tv==unique_tv[ii]], bm[tv==unique_tv[jj]]))$p.value})
      mean_idx[,ii,jj] <- sapply(unique_participant, FUN=function(p){
        with(subset(tab,participant==p), wilcox.test(bm[tv==unique_tv[ii]], bm[tv==unique_tv[jj]]))$p.value}) < alpha
      
      # Test for Difference in Variance
      var_stat <- sapply(unique_participant, FUN=function(p){
        with(subset(tab,(tv==unique_tv[ii] | tv==unique_tv[jj]) & participant==p), fligner.test(x=bm, g=tv))$p.value})
      var_p <- sapply(unique_participant, FUN=function(p){
        with(subset(tab,(tv==unique_tv[ii] | tv==unique_tv[jj]) & participant==p), fligner.test(x=bm, g=tv))$p.value})
      var_idx[,ii,jj] <- sapply(unique_participant, FUN=function(p){
        with(subset(tab,(tv==unique_tv[ii] | tv==unique_tv[jj]) & participant==p), fligner.test(x=bm, g=tv))$p.value}) < alpha
      
      meanvar_df[seq(nrow(meanvar_df)+1, nrow(meanvar_df)+length(unique_participant)),] <- 
        cbind(unique_participant,unique_tv[ii],unique_tv[jj],mean_stat,mean_p,var_stat,var_p)
    }
    
    if (ii == jj-1){
      pirateplot(bm~tv*participant, inf.method = 'ci', inf.disp='line',
                 data = subtab, theme = 3,
                 ylim = c(0,1), xaxt= "n", yaxt="n", 
                 pal=tv_col_vec[c(ii,jj)],
                 main=ifelse(ii==1 & jj!=1, levels(unique_tv)[jj], ""))
      
      # participant label
      xlocs <- seq(from=1.5,to=1.5+3*(length(unique_participant)-1), by=3)
      mtext(side=1, text=levels(subtab$participant), at=xlocs, cex.axis=1, cex.lab=1, cex=0.5, line=1)
      mtext(side=1, text="participant", at=mean(xlocs), cex.axis=1, cex.lab=1, cex=0.5, line=3)
      
      # biomarker label
      ylocs <- seq(0,1,0.1)
      mtext(2, text=paste(100*ylocs,"%",sep=""), at=ylocs, cex.axis=1, cex.lab=1, cex=0.5, line=1, las=1)
      mtext(2, text="biomarker", at=mean(ylocs), cex.axis=1, cex.lab=1, cex=0.5, line=5, las=0)
      
      # stats indicators
      points(x=xlocs[mean_idx[,ii,jj]]-0.5, y=rep(1,sum(mean_idx[,ii,jj])), pch=8, font=1, cex=2)
      points(x=xlocs[var_idx[,ii,jj]]+0.5, y=rep(1,sum(var_idx[,ii,jj])), pch=4, font=1, cex=2)
    }else if (jj==1 & ii!=length(unique_tv)){
      # tv label (row)
      plot.new()
      text(x=0.5, y=0.5, labels=unique_tv[ii], cex=2, font=2, las=1)
    }else if (ii<jj){
      pirateplot(bm~tv*participant, inf.method = 'ci', inf.disp='line',
                 data = subtab, theme = 3,
                 ylim = c(0,1), yaxt = "n", xaxt= "n", ylab="", 
                 pal=tv_col_vec[c(ii,jj)],
                 main=ifelse(ii==1 & jj!=1, levels(unique_tv)[jj], ""))
      
      # participant label
      xlocs <- seq(from=1.5,to=1.5+3*(length(unique_participant)-1), by=3)
      mtext(side=1, text=levels(subtab$participant), at=xlocs, cex.axis=1, cex.lab=1, cex=0.5, line=1)
      
      # stats indicators
      points(x=xlocs[mean_idx[,ii,jj]]-0.5, y=rep(1,sum(mean_idx[,ii,jj])), pch=8, font=1, cex=2)
      points(x=xlocs[var_idx[,ii,jj]]+0.5, y=rep(1,sum(var_idx[,ii,jj])), pch=4, font=1, cex=2)
    }else if (ii==length(unique_tv)-1 & jj==2){
      # tv legend
      plot(0,type='n',xlim=c(0,1),ylim=c(0,1),axes=FALSE,ann=FALSE)
      text(x=0.575, y=0.75, labels="place of articulation", font=2, cex=2)
      legend("center", legend=unique_tv, fill=tv_col_vec, cex=2, box.lty=0)
    }else if (ii==length(unique_tv)-1 & jj==3){
      # stats indicator legend
      plot(0,type='n',xlim=c(0,1),ylim=c(0,1),axes=FALSE,ann=FALSE)
      text(x=0.45, y=0.75, labels="statistical significance", font=2, cex=2)
      legend("center", legend=c("Mann-Whitney U Test","Fligner-Killeen Test"), pch=c(8,4), cex=2, box.lty=0)
    }else{
      plot(0,type='n',axes=FALSE,ann=FALSE)
    }
  }
}
dev.off()

# # PLOT STANDARD DEVIATION
# #########################
# 
# pdf(file.path(graphics_path,paste("sd.pdf",sep = "")))
# k <- 0
# for (idx in unique(tab$participant)){
#   k <- k+1
#   subtab <- tab[tab$participant==idx,]
#   a0 <- aggregate(bm ~ tv, FUN=sd, data=subtab)
#   a0$tv <- as.numeric(subtab$tv)
#   if (k==1){
#     plot(a0$tv+jit[k], a0$bm, col=tv_col_vec[k], type="o", pch=16, cex=2, lwd=4, cex.main=2,
#          xlim=c(1,5), ylim=c(0,0.3), xaxt="n", yaxt="n", xlab="", ylab="", main="standard deviation")
#     abline(h=seq(0,0.3,0.05), col="gray", lwd=2)
#     lines(a0$tv+jit[k], a0$bm, col=tv_col_vec[k], type="o", pch=16, cex=2, lwd=4)
#     axis(1, at=seq(1,5,1), cex.axis=1.5,
#          labels=c("bilabial", "coronal", "palatal", "velar", "pharyngeal"))
#     axis(2, at=seq(0,0.3,0.05), cex.axis=1.5, las=1,
#          labels=paste(100*seq(0,0.3,0.05),"%", sep=""))
#   }else{
#     lines(a0$tv+jit[k], a0$bm, col=tv_col_vec[k], type="o", pch=16, cex=2, lwd=4)
#   }
# }
# dev.off()
# 
# # PLOT MEAN
# ###########
# 
# pdf(file.path(graphics_path,paste("mean.pdf",sep = "")))
# k <- 0
# for (idx in unique(tab$participant)){
#   k <- k+1
#   subtab <- tab[tab$participant==idx,]
#   a0 <- aggregate(bm ~ tv, FUN=mean, data=subtab)
#   a0$tv <- as.numeric(subtab$tv)
#   if (k==1){
#     plot(a0$tv+jit[k], a0$bm, col=tv_col_vec[k], type="o", pch=16, cex=2, lwd=4, cex.main=2,
#          xlim=c(1,5), ylim=c(0,1), xaxt="n", yaxt="n", xlab="", ylab="", main="mean")
#     abline(h=seq(0,1,0.1), col="gray", lwd=2)
#     lines(a0$tv+jit[k], a0$bm, col=tv_col_vec[k], type="o", pch=16, cex=2, lwd=4)
#     axis(1, at=seq(1,5,1), cex.axis=1.5,
#          labels=c("bilabial", "coronal", "palatal", "velar", "pharyngeal"))
#     axis(2, at=seq(0,1,0.1), cex.axis=1.5, las=1,
#          labels=paste(100*seq(0,1,0.1),"%", sep=""))
#   }else{
#     lines(a0$tv+jit[k], a0$bm, col=tv_col_vec[k], type="o", pch=16, cex=2, lwd=4)
#   }
# }
# legend(x=1, y=1, legend=unique(tab$participant), fill=tv_col_vec, bg=rgb(1,1,1))
# dev.off()
