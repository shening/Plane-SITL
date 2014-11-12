# -*- coding: utf-8 -*-
"""
Created on Wed Nov 12 12:21:32 2014

@author: Lab580
"""
import csv
#---------Make function, read calibration box------

arrays = []
f = open("C:\Users\sebas_000\Documents\R code\New PDF\boundary2.txt",'r')
parser = csv.reader(f, delimiter='\t')
i = 0
  
for row in parser:
    if i > 1:
        print row
        arrays = numpy.vstack([arrays, row])
    elif i == 1:
        arrays.append(row)
    i+=1
    
    
#DeltaLat = float(msg[2]) - float(msg[0])
#DeltaLong = float(msg[7]) - float(msg[1])
#x = 0.5
#y = 0.5
#check = 0
#
#f.close()
#
#f = open('C:\Users\sebas_000\Documents\pythonwrite','w')              
#a = 1;
#f.write("%s\n" % (a))            
#f.close() # you can omit in most cases as the destructor will call if
#------------------------