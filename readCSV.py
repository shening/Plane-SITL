# -*- coding: utf-8 -*-
"""
Created on Wed Nov 12 10:19:18 2014

@author: Lab580
"""

import csv
import numpy
A = []
i_row = 0
with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/R_nav_coordinates.csv', 'rb') as f:
    reader = csv.reader(f)
    for row in reader:
        if i_row == 0:
            A.append(row)
            i_row+=1
        else:
            A = numpy.vstack([A,row])
        
        
with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints.csv', 'wb') as f:
    writer = csv.writer(f)
    writer.writerows(A)