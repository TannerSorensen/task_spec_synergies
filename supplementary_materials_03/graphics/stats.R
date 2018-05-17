# LOAD LIBRARIES
################

source(file.path("..","..","paper","graphics","require_libraries.R"))

# LOAD USER-DEFINED FUNCTIONS
#############################

source(file.path("..","..","paper","graphics","declare_user_defined_functions.R"))

# CHOOSE DATA-SET
#################

morphology_dataset <- FALSE

n <- 8*3*(3+1)

b <- matrix(nrow = n, ncol = 6)
z <- matrix(nrow = n, ncol = 6)
p <- matrix(nrow = n, ncol = 6)
jaw <- vector(mode = "numeric", length = n)
tng <- vector(mode = "numeric", length = n)
lip <- vector(mode = "numeric", length = n)
f <- vector(mode = "numeric", length = n)

k <- 1
for(f_val in seq(from = 20, to = 90, by = 10)){
  for(jaw_fac in c(1,2,3)){
    lip_fac <- 2
    for(tng_fac in c(4,6,8)){
      stats <- get_stats(jaw_fac,tng_fac,lip_fac,f_val,morphology_dataset)
      b[k,] <- stats[[1]]
      z[k,] <- stats[[2]]
      p[k,] <- stats[[3]]
      jaw[k] <- jaw_fac
      tng[k] <- tng_fac
      lip[k] <- lip_fac
      f[k] <- f_val
      k <- k+1
    }
    tng_fac <- 4
    lip_fac <- 3
    stats <- get_stats(jaw_fac,tng_fac,lip_fac,f_val,morphology_dataset)
    b[k,] <- stats[[1]]
    z[k,] <- stats[[2]]
    p[k,] <- stats[[3]]
    jaw[k] <- jaw_fac
    tng[k] <- tng_fac
    lip[k] <- lip_fac
    f[k] <- f_val
    k <- k+1
  }
}

ttls <- c("bilabial > velar","alveolar > velar","palatal > velar",
          "bilabial > pharyngeal","alveolar > pharyngeal","palatal > pharyngeal")
graphics_path <- file.path(".","histograms")
dir.create(graphics_path, showWarnings = FALSE)

# PLOT ESTIMATES
################

for(idx in seq(1,6,1)){
  pdf(file.path(graphics_path,paste(ttls[idx],"_b.pdf",sep="")), width=8, height=8, bg="white")
  
  #plot the entire data set (everything)
  if(idx==1 | idx==4){
    hist(b[,idx], breaks=seq(-60,+60,5), col="Red",xlim=c(-60,60), ylim=c(0,100), main=ttls[idx], xlab="parameter estimate",  cex.axis=2, cex.main=2, cex.lab=2)
  }else{
    hist(b[,idx], breaks=seq(-60,+60,5), col="Red",xlim=c(-60,60), ylim=c(0,100), main=ttls[idx], xlab="parameter estimate", ylab='', yaxt='n',  cex.axis=2, cex.main=2, cex.lab=2)
  }
  
  #then everything except one sub group (1 in this case)
  hist(b[jaw!=1,idx], breaks=seq(-60,+60,5), col="Blue", add=TRUE)
  
  #then everything except two sub groups (1&2 in this case)
  hist(b[jaw!=1 & jaw!=2,idx], breaks=seq(-60,+60,5), col="Green", add=TRUE)
  
  abline(v=0.05, lty=2)
  
  dev.off()
}

# PLOT P-VALUES
###############

for(idx in seq(1,6,1)){
  pdf(file.path(graphics_path,paste(ttls[idx],"_p.pdf",sep="")), width=8, height=8, bg="white")
  
  #plot the entire data set (everything)
  if(idx==1 | idx==4){
    hist(p[,idx], breaks=seq(0,1,0.025), col="Red",xlim=c(0,1), ylim=c(0,100), main="", xlab="adjusted p-value", cex.axis=2, cex.main=2, cex.lab=2)
  }else{
    hist(p[,idx], breaks=seq(0,1,0.025), col="Red",xlim=c(0,1), ylim=c(0,100), main="", xlab="adjusted p-value", ylab='', yaxt='n', cex.axis=2, cex.main=2, cex.lab=2)
  }
  
  #then everything except one sub group (1 in this case)
  hist(p[jaw!=1,idx], breaks=seq(0,1,0.025), col="Blue", add=TRUE)
  
  #then everything except two sub groups (1&2 in this case)
  hist(p[jaw!=1 & jaw!=2,idx], breaks=seq(0,1,0.025), col="Green", add=TRUE)
  
  abline(v=0.05, lty=2)
  
  dev.off()
}
