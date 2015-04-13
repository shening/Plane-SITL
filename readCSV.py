# -*- coding: utf-8 -*-
"""
Created on Wed Nov 12 10:19:18 2014

@author: Lab580
"""

import csv
import re
import numpy
header = 'QGC WPL 110\n'
A = []
i_row = 0
with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/boundary2.txt', 'rb') as f:
    reader = csv.reader(f,delimiter='\t')
    for row in reader:
        if i_row == 0:
            x = 0
            i_row+=1
        elif i_row == 1:
            A.append(row)
            i_row+=1
        else:
            A = numpy.vstack([A,row])
        
        
with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/pythonboundary.csv', 'wb') as f:
    writer = csv.writer(f)
    f.write(header)
    writer.writerows(A)
    
    

plume_box = []
f = open("C:/Users/sebas_000/Documents/Programming/Plane-SITL/pythonboundary.csv")
parser = csv.reader(f, delimiter=',')
row_init = 0
  
for row in parser:
    if row_init > 1:
        print row
        plume_box = numpy.vstack([plume_box, row])
    elif row_init == 1:
        plume_box.append(row)
    row_init+=1

DeltaLat = -(float(plume_box[1][8]) - float(plume_box[2][8]))
DeltaLong = (float(plume_box[1][9]) - float(plume_box[4][9])) 

plume_box[4][8] = plume_box[2][8]
plume_box[4][9] = plume_box[2][9]
plume_box[1][8] = plume_box[4][8]
plume_box[1][9] = float(plume_box[4][9]) + DeltaLong
plume_box[2][8] = float(plume_box[4][8]) + DeltaLat
plume_box[2][9] = float(plume_box[4][9]) + DeltaLong
plume_box[3][8] = float(plume_box[4][8]) + DeltaLat
plume_box[3][9] = plume_box[4][9] 


with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/pythonboundary.txt', 'wb') as f:
    writer = csv.writer(f)
    f.write(header)
    writer.writerows(plume_box)