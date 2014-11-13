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
  
  
  return(h2*3/4+h)
}


count = 0
y = 0
prevcount = 0
init = 0
zlim <- c(0,1.5)
pic_count = 0

##Generate the "training" data from the 9 way oints (actually, the training data might be larger because we will also be sampling between waypoints, but don't worry about that for now).

# 
# grid.training[1,] = c(0.1,0.5)
# grid.training[2,] = c(0.5,0.9)
# grid.training[3,] = c(0.9,0.5)
# grid.training[4,] = c(0.5,0.1)
# grid.training[5,] = c(0.2,0.2)
# grid.training[6,] = c(0.2,0.8)
# grid.training[7,] = c(0.8,0.8)
# grid.training[8,] = c(0.8,0.2)
# grid.training[9,] = c(0.5,0.5)


# grid.training[7,] = c(0.2,0.1)
# grid.training[2,] = c(0.1,0.2)
# grid.training[3,] = c(0.8,0)
# grid.training[4,] = c(0.6,0)
# grid.training[5,] = c(1,0.3)
# grid.training[6,] = c(1,0.1)
# grid.training[1,] = c(1,0.2)

#BAD+++++++++++++++++++++
# grid.training[1,] = c(0.1,0.1)
# grid.training[2,] = c(0.2,0.1)
# grid.training[3,] = c(0.3,0.1)
# grid.training[6,] = c(0.1,0.2)
# grid.training[5,] = c(0.2,0.2)
# grid.training[4,] = c(0.3,0.2)
# grid.training[7,] = c(0.1,0.4)
# 
# grid.training[8,] = c(0.2,0.4)
# grid.training[9,] = c(0.3,0.4)
# ++++++++++++++++++


# 
# grid.training[1,] = c(0.2,0.1)
# grid.training[2,] = c(0.4,0.1)
# grid.training[3,] = c(0.6,0.1)
# grid.training[6,] = c(0.2,0.3)
# grid.training[5,] = c(0.4,0.3)
# grid.training[4,] = c(0.6,0.3)
# grid.training[7,] = c(0.2,0.6)
# 
# grid.training[8,] = c(0.4,0.6)
# grid.training[9,] = c(0.6,0.6)





# grid.training[3,] = c(0.3,0.1)
# grid.training[6,] = c(0.1,0.2)
# grid.training[5,] = c(0.2,0.2)
# grid.training[4,] = c(0.3,0.2)
# grid.training[7,] = c(0.1,0.4)
# 
# grid.training[8,] = c(0.2,0.4)
# grid.training[9,] = c(0.3,0.4)

# 
# grid.training[10,] = c(0.9,0.1)
# grid.training[11,] = c(0.9,0.4)
# grid.training[12,] = c(0.9,0.6)
# grid.training[13,] = c(0.9,0.4)
# grid.training[14,] = c(0.9,0.5)
# if(count > 9 )
# {
#   grid.training[count,] = c(s.max.estimated[1],s.max.estimated[2])
#   
# }
# grid.training[11,] = c(0.6,0.6
prev_training_size = 0

while(count < 50)
{

  

grid.training = matrix(0, nrow=0, ncol=2)
  
pythondata = read.csv("C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints.csv");
  
for (i in 1:dim(pythondata)[1])
  {
    
    
    grid.training = rbind(grid.training,c(pythondata[i,1],pythondata[i,2]))
    
  }

training_size = dim(grid.training)[1]

if(training_size != prev_training_size)
{
prev_training_size = training_size  
ngrid.training = dim(grid.training)[1]
towrite = 5

# for(i in dim(grid.training)[1])
#      {
#  
#   towrite = append(towrite, grid.training[i,])
# }
# write(towrite, file = "dataTest", ncolumns = 1000, sep = ",")
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
#lines(grid.training)
# text(grid.training[1,1]+0.02, grid.training[1,2]-0.02, expression(paste(s[1])))
# text(grid.training[2,1]+0.02, grid.training[2,2]-0.02, expression(paste(s[2])))
# text(grid.training[3,1]+0.02, grid.training[3,2]-0.02, expression(paste(s[3])))
# text(grid.training[4,1]+0.02, grid.training[4,2]-0.02, expression(paste(s[4])))
# text(grid.training[5,1]+0.02, grid.training[5,2]-0.02, expression(paste(s[5])))
# text(grid.training[6,1]+0.02, grid.training[6,2]-0.02, expression(paste(s[6])))
# text(grid.training[7,1]+0.02, grid.training[7,2]-0.02, expression(paste(s[7])))
# text(grid.training[8,1]+0.02, grid.training[8,2]-0.02, expression(paste(s[8])))
# text(grid.training[9,1]+0.02, grid.training[9,2]-0.02, expression(paste(s[9])))
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
#  for(i in 1:9)
# 	{
# 	   if(i <= count)
# 	   {
# 	   	y[i] = traininghumidity[i]
# 	   }
# 	   else
# 	     {
#               y[i] = 0
# 	     }
# 	}
# i =0
##These are naive, off-the-shelve values for the parameters controlling smoothing and interpolation.  A real excersice would aim at getting these values as part of the monitoring procedure, but I am trying to keep it as simple as possible for now
# beta = mean(y)
# sigma2 = 0.2*var(y)
# tau2   = 0.8*var(y)
# lambda = sqrt(2)/3  ##This is the maximum distance between any two points in the map, divided by 3.  Don't ask why :)

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
# text(grid.training[1,1]+0.02, grid.training[1,2]-0.02, expression(paste(s[1])))
# text(grid.training[2,1]+0.02, grid.training[2,2]-0.02, expression(paste(s[2])))
# text(grid.training[3,1]+0.02, grid.training[3,2]-0.02, expression(paste(s[3])))
# text(grid.training[4,1]+0.02, grid.training[4,2]-0.02, expression(paste(s[4])))
# text(grid.training[5,1]+0.02, grid.training[5,2]-0.02, expression(paste(s[5])))
# text(grid.training[6,1]+0.02, grid.training[6,2]-0.02, expression(paste(s[6])))
# text(grid.training[7,1]+0.02, grid.training[7,2]-0.02, expression(paste(s[7])))
# text(grid.training[8,1]+0.02, grid.training[8,2]-0.02, expression(paste(s[8])))
# text(grid.training[9,1]+0.02, grid.training[9,2]-0.02, expression(paste(s[9])))
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
# text(grid.training[1,1]+0.02, grid.training[1,2]-0.02, expression(paste(s[1])))
# text(grid.training[2,1]+0.02, grid.training[2,2]-0.02, expression(paste(s[2])))
# text(grid.training[3,1]+0.02, grid.training[3,2]-0.02, expression(paste(s[3])))
# text(grid.training[4,1]+0.02, grid.training[4,2]-0.02, expression(paste(s[4])))
# text(grid.training[5,1]+0.02, grid.training[5,2]-0.02, expression(paste(s[5])))
# text(grid.training[6,1]+0.02, grid.training[6,2]-0.02, expression(paste(s[6])))
# text(grid.training[7,1]+0.02, grid.training[7,2]-0.02, expression(paste(s[7])))
# text(grid.training[8,1]+0.02, grid.training[8,2]-0.02, expression(paste(s[8])))
# text(grid.training[9,1]+0.02, grid.training[9,2]-0.02, expression(paste(s[9])))
points(s.max.f.estimated[1], s.max.EI.estimated[2], pch=19)
text(s.max.f.estimated[1]+.02, s.max.EI.estimated[2]+0.02, "Estimated maximum", pos=4)
dev.print(dev=pdf, file="function_est.pdf")
dev.copy(jpeg,filename=paste("C:/Users/sebas_000/Documents/R code/pic",pic_count,".jpg"))
dev.off ();
pic_count = pic_count+1
Sys.sleep(0.2) 

# if(count == 9)
# {count = 0
# }
# count = count + 1
# grid.training[1,] = c(s.max.estimated[1],s.max.estimated[2])
# 
print("DONE FIRST RUN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")


#This appends the next measured value to the training grid
#grid.training = rbind(grid.training,c(s.max.EI.estimated[1],s.max.EI.estimated[2]))



# if(count == 5)
# {
#   grid.training = rbind(grid.training,c(0.75,0.75))
# }




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
  dev.set(dev.list()[4])
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

if(init == 0)
{
  X11()
  plot(count,percent,xlim=c(1, 40),ylim=c(0,50))
  title(main = "% Error of predicted plume", font.main = 4)
}
else
{
  dev.set(dev.list()[5])
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

# for(i in 1:81)
# {
#   print(i)
#   points(i/10, i/10, pch=12)
#   Sys.sleep(1) 
# }

# dev.set(dev.list()[1])

# Ex = matrix(EI, nrow=ngrid, ncol=ngrid)
# y <- grid[which(Ex>max(EI)-max(EI)/4),]
# points(y[,1], y[,2], pch=10)




