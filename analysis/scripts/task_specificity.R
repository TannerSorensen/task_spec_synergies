require(lme4)
require(RColorBrewer)
require(multcomp)
require(rptR)

# SET GRAPHICS PATH
###################

graphics_path <- file.path("..","graphics")

# CHOOSE DATA-SET
#################

morphology_dataset <- FALSE

# READ IN DATA-SET
##################

tab <- read.csv(file.path("..","mat","strategies.csv"))
subject_key <- read.csv(file.path("..","mat","artstrat_subjects.csv"))
if(morphology_dataset==TRUE){
  subject_ids <- with(subject_key,subject_id[repeatability_dataset==FALSE])
}else{
  subject_ids <- with(subject_key,subject_id[repeatability_dataset==TRUE])
}

if(morphology_dataset==TRUE){
  tab <- subset(tab,n_jaw==1 & n_tng==6 & n_lip==2 & participant%in%subject_ids)
}else{
  tab <- subset(tab,repetition==1 & n_jaw==1 & n_tng==6 & n_lip==2 & participant%in%subject_ids)
}

# OBTAIN BIOMARKER VALUES
#########################

tab$lambda <- with(tab,ifelse(tv==1,jaw/(jaw+lip),jaw/(jaw+tng)))

# PRINT HISTOGRAMS
##################

tv_loc <- c("bilabial place","alveolar place","palatal place","velar place","pharyngeal place")

colrs <- rainbow(length(subject_ids))
spacing <- 2
for(i in seq(1,5)){
  pdf(file.path(graphics_path,paste("histogram_",sub(" ","_",tv_loc[i]),".pdf",sep = "")))
  par(mar=c(5,6,4,1)+.1)
  with(tab,hist(lambda[tv==i],main=tv_loc[i],
                   yaxt="n",ylab="frequency",ylim=c(-length(subject_ids)*spacing,30),
                   xaxt="n",xlab="percent jaw contribution",xlim=c(0,1),
                   cex.axis=2,cex.lab=2,cex.main=2))
  yul <- par("usr")[4] - par("usr")[4] %% 10
  axis(1, at=seq(0,1,length.out=5), labels=seq(0,100,length.out=5), cex.axis=2)
  axis(2, at=seq(0,yul,length.out=(yul+1)/10),cex.axis=2)
  k <- 1
  for(j in subject_ids){
    idx <- with(tab, tv==i&participant==j)
    with(tab,points(lambda[idx],rep(-k*spacing,sum(idx)),col="#000000",bg=colrs[k],pch=21,cex=2))
    k <- k+1
  }
  dev.off()
}

# PERFORM STATISTICAL TEST
##########################

tab$tv <- factor(tab$tv)
contrasts(tab$tv) <- contr.treatment(5, base = 4)
tab$participant <- factor(tab$participant)
m0 <- lmer(lambda ~ 1 + tv + (1+tv|participant), tab, REML=TRUE)
fixef(m0)
summary(m0)
(summary(glht(m0,linfct=c("tv1 = 0","tv2 = 0","tv3 = 0","tv5=0"))))
