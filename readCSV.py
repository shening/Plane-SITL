# -*- coding: utf-8 -*-
"""
Created on Wed Nov 12 10:19:18 2014

@author: Lab580
"""

import csv
import numpy
A = ['V1', 'V2']
with open('foo.csv', 'rb') as f:
    reader = csv.reader(f)
    for row in reader:
        print row
        A = numpy.vstack([A,row])
        
        
with open('foowrite.csv', 'wb') as f:
    writer = csv.writer(f)
    writer.writerows(A)