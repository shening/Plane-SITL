



# write.csv(grid.training, file = "C:/Users/sebas_000/Documents/Programming/Plane-SITL/foo2.csv", row.names = FALSE)

pythondata = read.csv("C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints.csv");
grid.training2 = matrix(0, nrow=0, ncol=2)
for (i in 1:dim(pythondata)[1])
{
  print(pythondata[i,1])
  grid.training2 = rbind(grid.training2,c(pythondata[i,1],pythondata[i,2]))
  
}

