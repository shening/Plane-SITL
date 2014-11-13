# -*- coding: utf-8 -*-
"""
Created on Wed Nov 12 12:21:32 2014

@author: Lab580
"""
import csv
#---------Make function, read calibration box------

arrays = []
f = open("C:/Users/sebas_000/Documents/Programming/Plane-SITL/boundary2.txt")
parser = csv.reader(f, delimiter='\t')
i = 0
  
for row in parser:
    if i > 1:
        print row
        arrays = numpy.vstack([arrays, row])
    elif i == 1:
        arrays.append(row)
    i+=1
    
    
DeltaLat = -(float(arrays[1][8]) - float(arrays[2][8]))
DeltaLong = (float(arrays[1][9]) - float(arrays[4][9]))
x = 0
y = 0
check = 0
#Use the 4th waypoint (there are 4 waypoints in counter clockwise orientation starting in lower right corner)
Lat = float(arrays[4][8]) + y*DeltaLat
Long = float(arrays[4][9]) + x*DeltaLong
print Lat
print Long

f.close()

#f = open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/pythonwrite','w')              
#a = 1;
#f.write("%s\n" % (a))            
#f.close() # you can omit in most cases as the destructor will call if
#------------------------