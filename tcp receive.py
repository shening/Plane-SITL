import socket
import re

import numpy
import csv


TCP_IP = '127.0.0.1'
TCP_PORT = 5030
BUFFER_SIZE = 100  # Normally 1024, but we want fast response

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

s.bind((TCP_IP, TCP_PORT))
s.listen(1)


conn, addr = s.accept()
print 'Connection address:', addr
conn.settimeout(5.0)


#----------------------------------------
#Config plume box
#------------------------------------

plume_box = []
f = open("C:/Users/sebas_000/Documents/Programming/Plane-SITL/boundary2.txt")
parser = csv.reader(f, delimiter='\t')
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
#-------------------------------------


#---Read R code waypoints 
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

wp_count = 1
x = float(A[wp_count][0])
y = float(A[wp_count][1])
lat = float(plume_box[4][8]) + y*DeltaLat
lng = float(plume_box[4][9]) + x*DeltaLong
alt = 100
msg = '|'+'alt'+'|'+str(alt)+'|'+'lat'+'|'+str(lat)+'|'+'lng'+'|'+str(lng)+'|'
wp_count += 1
conn.send(msg)
print msg
time_count = 0


Plane_pos = ['V1' 'V2']



while True:
 


    A = []
    i_row = 0
    with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/R_nav_coordinates.csv', 'rb') as R_file:
        reader = csv.reader(R_file)
        for row in reader:
            if i_row == 0:
                A.append(row)
                i_row+=1
            else:
                A = numpy.vstack([A,row])
   

    
    print 'Running 1'
    try:
        data = conn.recv(BUFFER_SIZE)
    except:
        conn, addr = s.accept()
        conn.settimeout(5.0)
        
    list = re.split('\|+',data)
    
    for position, item in enumerate(list):
        if item == "alt":
            print "Altitude:", list[position+1]
            cur_alt = list[position+1]
        elif item == "heading":
            print "Heading:", list[position+1]
            cur_heading = list[position+1]
        elif item == "lat":
            print "Latitude:", list[position+1]
            cur_lat = float(list[position+1])
            cur_y = (cur_lat - float(plume_box[4][8]))/DeltaLat
        elif item == "lng":
            print "Longitude:", list[position+1]
            cur_lng = float(list[position+1])
            cur_x = (cur_lng - float(plume_box[4][9]))/DeltaLong
            cur_pos = [cur_x, cur_y]
            Plane_pos = numpy.vstack([Plane_pos,cur_pos])
            with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints.csv', 'wb') as Pl_file:
                writer = csv.writer(Pl_file)
                writer.writerows(Plane_pos)
            
        elif item == "gndspeed":
            print "Groundspeed:", list[position+1]
            cur_gndspeed = list[position+1]
        elif item == "wpdst":
            print "Waypoint distance:", list[position+1]
            wp_dst = float(list[position+1])
            time_count = time_count + 1
            print 'Checking wpdst'
            if wp_dst < 100:
                
                x = float(A[wp_count][0])
                y = float(A[wp_count][1])
                lat = float(plume_box[4][8]) + y*DeltaLat
                lng = float(plume_box[4][9]) + x*DeltaLong
                alt = 100
                msg = '|'+'alt'+'|'+str(alt)+'|'+'lat'+'|'+str(lat)+'|'+'lng'+'|'+str(lng)+'|'
                wp_count += 1

                
                
             
            conn.send(msg)
            print msg

conn.close()
#                        
#
#    
        

