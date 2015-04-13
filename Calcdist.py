# -*- coding: utf-8 -*-
"""
Created on Tue Mar 31 13:45:21 2015

@author: Lab580
"""
import csv
import re
import numpy

from scipy.spatial import distance

a = (1,1)
b = (1,2)
dst = distance.euclidean(a,b)
filecount =4
Points = [300]



#count = 0
#for line in open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints_log'+str(filecount)+'.csv').xreadlines(  ): count += 1

for filecount in range(1,50):
    
    num_lines = sum(1 for line in open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints'+str(filecount)+'.csv'))
    Points = numpy.vstack([Points,num_lines]) 
    A = []
    i_row = 0
    dist_total = 0 
    with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints_log'+str(filecount)+'.csv', 'rb') as f:
        reader = csv.reader(f,delimiter=',')
        for row in reader:
            if i_row == 0:
                x = 0
                i_row+=1
            elif i_row == 1:
                A.append(row)
                i_row+=1
            else:
                i_row+=1
                A = numpy.vstack([A,row])
                
                
    for count in range(1,i_row-2):
        dist_total += distance.euclidean((float(A[count][0]),float(A[count][1])),(float(A[count+1][0]),float(A[count+1][1])))
        
#        
with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Results.csv', 'wb') as f:
    writer = csv.writer(f)
#    f.write(header)
    writer.writerows(Points)