# -*- coding: utf-8 -*-
"""
Created on Wed Nov 12 10:19:18 2014

@author: Lab580
"""

import csv
import re
import numpy
A = []
i_row = 0
with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/boundary2.txt', 'rb') as f:
    reader = csv.reader(f,delimiter='\t')
    for row in reader:
        if i_row == 0:
            x = 0
            i_row+=1
        elif i_row == 1:
            A.append(row[0].replace(',', '\t'))
            i_row+=1
        else:
            A = numpy.vstack([A,row[0].replace(',', '\t')])
        
        
with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/boundarytest.csv', 'wb') as f:
    writer = csv.writer(f)
    writer.writerows(A)