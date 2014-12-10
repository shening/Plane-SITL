##rm(list=ls())
library(mvtnorm)
library(fields)
library(MASS)
graphics.off()

##Function to construct the covariance function for the spatial field
construct.Omega = function(s1, s2, tau2, lambda){
  n1    = dim(s1)[1]
  n2    = dim(s2)[1]
  Omega = matrix(0, nrow=n1, ncol=n2)
  for(i in 1:n1){
    for(j in 1:n2){
      Omega[i,j] = tau2*exp(-(sqrt(sum((s1[i,]-s2[j,])^2)))/lambda)
    }
  }
  return(Omega)
}


##Function that evaluates the true underlying function that generates the data
humidity = function(s,x1,y1,x2,y2){
  s.maxh1 = c(x1,y1)  #Coordinates of the maximum of the humidity function
  s.maxh2 = c(x2,y2)
  n = dim(s)[1]
  h = rep(0, n)
  h2 = rep(0, n)
  for(i in 1:n){
    h[i] = exp(-2*sum((s[i,]-s.maxh1)^2))
    h2[i] = exp(-6*sum((s[i,]-s.maxh2)^2))
  }
  
  
  #return(h2*3/4+h)
  return(h)
}


count = 0
y = 0
prevcount = 0
init = 0
zlim <- c(0,1.5)
pic_count = 0


prev_training_size = 0

while(count < 2000)
{

  

grid.training = matrix(0, nrow=0, ncol=2)
  
pythondata = read.csv("C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints.csv");
  
for (i in 1:dim(pythondata)[1])
  {
    
    
    grid.training = rbind(grid.training,c(pythondata[i,1],pythondata[i,2]))
    
  }
Plane_path = matrix(0, nrow=0, ncol=2)

pythondata = read.csv("C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints_log.csv");

for (i in 1:dim(pythondata)[1])
{
  
  
  Plane_path = rbind(Plane_path,c(pythondata[i,1],pythondata[i,2]))
  
}


training_size = dim(grid.training)[1]

if(training_size != prev_training_size & training_size > 3)
{
prev_training_size = training_size  
ngrid.training = dim(grid.training)[1]
towrite = 5


##Generate the grid over which predictions will be made
ngrid = 50
grid  = matrix(0, nrow=ngrid*ngrid, ncol=2)
grid[,1] = rep(seq(0,1,length=ngrid),ngrid)
grid[,2] = rep(seq(0,1,length=ngrid),each=ngrid)


##Visualize the true function along with the location of the training waypoints

truehumidity = humidity(grid, 0.8, 0.8,0.1,0.0)

#truehumidity2 = humidity(grid,0,0)
if(init == 0)
{
  X11()
}
else
{
  dev.set(dev.list()[1])
}
par(mar=c(4,4,1,1)+0.2)



# image(matrix(truehumidity, nrow=ngrid, ncol=ngrid),legend.only=TRUE,col = heat.colors(50),  ylab="Longitude", xlab="Latitude")
image.plot(matrix(truehumidity, nrow=ngrid, ncol=ngrid),col = heat.colors(100),  ylab="Longitude", xlab="Latitude")
title(main = "Actual Plume", font.main = 4)
points(grid.training[,1], grid.training[,2], pch=19)

dev.print(dev=pdf, file="poc_true.pdf")
dev.copy(jpeg,filename=paste("C:/Users/sebas_000/Documents/R code/pic",pic_count,".jpg"))
dev.off ();
pic_count = pic_count+1


##Generate the actual observations over the training grid (these involve noise)
traininghumidity = humidity(grid.training,0.8, 0.8,0.1,0.0)# + rnorm(ngrid.training, 0, 0.025)


## Negative of marginal likelihood function. Target for optimal hyperparameter selection. 
marginal.likelihood=function(hyper.params,measurements,points){
	a1=2
	b1=.5*var(measurements)
	a2=2
	b2=.5*var(measurements)
	c=1
	d=-sqrt(2)/log(.05)
	lambda=hyper.params[1]
	sigma2=hyper.params[2]
	tau2=hyper.params[3]
	Psi=sigma2*diag(,length(measurements))+construct.Omega(points, points , tau2, lambda)
	Psi.inv=solve(Psi)
	beta.hat=as.numeric(colSums(Psi.inv)%*%measurements)/sum(Psi.inv)
	ml=-.5*log(det(Psi))-.5*as.numeric((measurements-beta.hat)%*%Psi.inv%*%(measurements-beta.hat))-(a1+1)*log(sigma2)-b1/sigma2-(a2+1)*log(tau2)-b2/tau2+(c-1)*log(lambda)-lambda/d
	return(-1*ml)
}

########################################################################
########################################################################
##Do the actual work
y = traininghumidity


## Get the maximum of the marginal likelihood and extract the empirical Bayes estimates for the parameters.
opt=constrOptim(c(.47,sqrt(var(y)),sqrt(var(y))),marginal.likelihood,NULL,diag(,3),rep(1e-6,3),measurements=y,points=grid.training)
lambda=opt$par[1]
sigma2=opt$par[2]
tau2=opt$par[3]
Psi=sigma2*diag(,length(y))+construct.Omega(grid.training, grid.training , tau2, lambda)
Psi.inv=solve(Psi)
beta=as.numeric(colSums(Psi.inv)%*% y)/sum(Psi.inv)


## Compute posterior predictive mean and variance. 
oneso        = rep(1, ngrid.training)
Omegaoo     = construct.Omega(grid.training, grid.training, tau2, lambda)
Omegaoo.inv = ginv(Omegaoo)#solve(Omegaoo)  #solve computes the inverse of a matrix
Omegapo = construct.Omega(grid, grid.training, tau2, lambda)
onesp   = rep(1, ngrid*ngrid)
y.mean = beta*onesp+Omegapo%*%Omegaoo.inv%*%(solve(diag(rep(1,ngrid.training))/sigma2 + Omegaoo.inv)%*%(y/sigma2 + Omegaoo.inv%*%oneso*beta)-oneso*beta)
y.var=sigma2+tau2-diag(Omegapo%*%Omegaoo.inv%*%t(Omegapo)+Omegapo%*%Omegaoo.inv%*%solve(diag(rep(1,ngrid.training))/sigma2 + Omegaoo.inv)%*%Omegaoo.inv%*%t(Omegapo))  


## Calculate expected improvement over the working grid
y.max=max(y)
EI = sqrt(y.var)*dnorm((y.mean-y.max)/sqrt(y.var))+(y.mean-y.max)*pnorm((y.mean-y.max)/sqrt(y.var))


s.max.EI.estimated = grid[which.max(EI),]  #These are the coordinates of the (currently estimated) maximum
s.max.f.estimated = grid[which.max(y.mean),]  #These are the coordinates of the (currently estimated) maximum

print(paste("The coordinates of the next location to visit are ", paste(s.max.EI.estimated, collapse=" "), ".  This is our current best guess for the location of the maximum expected improvement."))
# 
# for(z in 51:51)
# {
#   EI[z] = min(EI)
# }
if(init == 0)
{
  X11()
}
else
{
  dev.set(dev.list()[2])
}
par(mar=c(4,4,1,1)+0.2)


# image(matrix(EI, nrow=ngrid, ncol=ngrid), legend.only=TRUE,col = heat.colors(50),  ylab="Longitude", xlab="Latitude")
image.plot(matrix(EI, nrow=ngrid, ncol=ngrid),col = heat.colors(100),  ylab="Longitude", xlab="Latitude")
title(main = "Expected Improvement", font.main = 4)
points(grid.training[,1], grid.training[,2], pch=19)

points(s.max.EI.estimated[1], s.max.EI.estimated[2], pch=19)
text(s.max.EI.estimated[1]+.02, s.max.EI.estimated[2]+0.02, paste("Max EI:",EI[which.max(EI)]), pos=4)
dev.print(dev=pdf, file="expectedimprovement_est.pdf")
dev.copy(jpeg,filename=paste("C:/Users/sebas_000/Documents/R code/pic",pic_count,".jpg"))
dev.off ();
pic_count = pic_count+1




print(paste("The coordinates of the next location to visit are ", paste(s.max.f.estimated, collapse=" "), ".  This is our current best guess for the location of the maximum expected improvement."))


if(init == 0)
{
  X11()
}
else
{
  dev.set(dev.list()[3])
}
par(mar=c(4,4,1,1)+0.2)
# image(matrix(y.mean, nrow=ngrid, ncol=ngrid), col = heat.colors(50),ylab="Longitude", xlab="Latitude")
image.plot(matrix(y.mean, nrow=ngrid, ncol=ngrid), col = heat.colors(100),ylab="Longitude", xlab="Latitude")

title(main = "Predicted Plume", font.main = 4)
points(grid.training[,1], grid.training[,2], pch=19)


points(s.max.f.estimated[1], s.max.EI.estimated[2], pch=19)
text(s.max.f.estimated[1]+.02, s.max.EI.estimated[2]+0.02, "Estimated maximum", pos=4)
dev.print(dev=pdf, file="function_est.pdf")
dev.copy(jpeg,filename=paste("C:/Users/sebas_000/Documents/R code/pic",pic_count,".jpg"))
dev.off ();
pic_count = pic_count+1
Sys.sleep(0.2) 


if(init == 0)
{
  X11()
}
else
{
  dev.set(dev.list()[4])
}
image.plot(matrix(y.mean, nrow=ngrid, ncol=ngrid), col = heat.colors(100),ylab="Longitude", xlab="Latitude")
title(main = "Predicted Plume with Path", font.main = 4)

print("DONE FIRST RUN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

points(Plane_path[,1], Plane_path[,2], pch=20, cex=.2)
dev.copy(jpeg,filename=paste("C:/Users/sebas_000/Documents/R code/pic",pic_count,".jpg"))
dev.off ();
pic_count = pic_count+1

# if(count == 5)
# {
#   grid.training = rbind(grid.training,c(0.75,0.75))
# }
if (dim(grid.training)[1] > 8)
{
  R_data = read.csv("C:/Users/sebas_000/Documents/Programming/Plane-SITL/R_nav_coordinates.csv");
  grid.training2 = matrix(0, nrow=0, ncol=2)
  for (i in 1:dim(R_data)[1])
  {
    print(R_data[i,1])
    grid.training2 = rbind(grid.training2,c(R_data[i,1],R_data[i,2]))
    
  }
  #This appends the next measured value to the training grid
  grid.training2 = rbind(grid.training2,c(s.max.EI.estimated[1],s.max.EI.estimated[2]))
  
  
  write.csv(grid.training2, file = "C:/Users/sebas_000/Documents/Programming/Plane-SITL/R_nav_coordinates.csv", row.names = FALSE)
}

predicted = matrix(y.mean, nrow=ngrid, ncol=ngrid)
actual = matrix(truehumidity, nrow=ngrid, ncol=ngrid)
EIm = matrix(EI, nrow=ngrid, ncol=ngrid)
act <-rep(NA,50)
pred <-rep(NA,50)
EId <- rep(NA,50)

for(i in 1:dim(predicted)[1])
{
  pred[i] = predicted[i,i]
  act[i] = actual[i,i]
  EId[i] = EIm[i,i]
}

if(init == 0)
{
  X11()
}
else
{
  dev.set(dev.list()[5])
}

old.par <- par(mfrow=c(2, 1))

plot(act, main="Actual vs predicted(red)", font.main = 4)
points(pred,col= "red")
plot(EId, main="Expected Improvement (diagonal)", font.main = 4, ylim = c(0,0.01))
par(old.par)


# plot(act)
# title(main = "Actual vs predicted(red)", font.main = 4)
# points(pred,col= "red")
dev.copy(jpeg,filename=paste("C:/Users/sebas_000/Documents/R code/pic",pic_count,".jpg"))
dev.off ();
pic_count = pic_count+1

diff = sqrt((matrix(y.mean, nrow=ngrid, ncol=ngrid) - matrix(truehumidity, nrow=ngrid, ncol=ngrid))^2)

#image(diff, ylab="Longitude", xlab="Latitude")

diffmean = mean(rowMeans(diff))
truemean = mean(rowMeans(matrix(truehumidity, nrow=ngrid, ncol=ngrid)))

percent = (diffmean/truemean )*100
print(percent)

if(init == 0)
{
  X11()
  plot(count,percent,xlim=c(1, 40),ylim=c(0,50))
  title(main = "% Error of predicted plume", font.main = 4)
}
else
{
  dev.set(dev.list()[6])
  points(count,percent)
}


# if(init == 0)
# {
#   X11()
#   
# }
# else
# {
#   dev.set(dev.list()[6])
# }
# 
# plot(EId)


count = count + 1

init = 1
}
else
{Sys.sleep(0.2) 
 print(paste("NO NEW DATA!!!")) }


}


# dev.set(dev.list()[1])

# Ex = matrix(EI, nrow=ngrid, ncol=ngrid)
# y <- grid[which(Ex>max(EI)-max(EI)/4),]
# points(y[,1], y[,2], pch=10)




