



# write.csv(grid.training, file = "C:/Users/sebas_000/Documents/Programming/Plane-SITL/foo2.csv", row.names = FALSE)

pythondata = read.csv("C:/Users/sebas_000/Documents/R Code/2.5 by 2.5 PDF/grid 45 bank limit/Plane_flightpoints_log.csv");
grid.training2 = matrix(0, nrow=0, ncol=2)
for (i in 1:dim(pythondata)[1])
{
  grid.training2 = rbind(grid.training2,c(pythondata[i,1],pythondata[i,2]))
  
}
dist = 0
for (i in 2:dim(grid.training2)[1])
{
  dist = dist + sqrt((grid.training2[i,1] - grid.training2[i-1,1])^2 + (grid.training2[i,2] - grid.training2[i-1,2])^2)
}

print(dist)