



write.csv(grid.training, file = "foo2.csv", row.names = FALSE)

test = read.csv("foowrite.csv")
grid.training2 = matrix(0, nrow=0, ncol=2)
for (i in 1:dim(test)[1])
{
  print(test[i,1])
  grid.training2 = rbind(grid.training2,c(test[i,1],test[i,2]))
  
}

