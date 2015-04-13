import socket
import re
import time
import numpy
import csv
import shutil


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
simulation_iter = 1
A = []
header = 'QGC WPL 110\n'
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
#-------------------------------------
#------------Run config Params-------
grid_nav =1
standard_nav = 1

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
prev_wp_count = 0
wp_count = 1
x = float(A[wp_count][0])
y = float(A[wp_count][1])
lat = float(plume_box[4][8]) + y*DeltaLat
lng = float(plume_box[4][9]) + x*DeltaLong
alt = 200
msg = '|'+'alt'+'|'+str(alt)+'|'+'lat'+'|'+str(lat)+'|'+'lng'+'|'+str(lng)+'|'

conn.send(msg)
print msg



Plane_pos = ['V1', 'V2']
#Plane_pos = numpy.vstack([Plane_pos,[0.1,0.1]])
#Plane_pos = numpy.vstack([Plane_pos,[0.9,0.3]])
#Plane_pos = numpy.vstack([Plane_pos,[0.5,0.2]])
#Plane_pos = numpy.vstack([Plane_pos,[0.7,0.4]])
#Plane_pos = numpy.vstack([Plane_pos,[0.9,0.3]])
#Plane_pos = numpy.vstack([Plane_pos,[0.5,0.2]])
#Plane_pos = numpy.vstack([Plane_pos,[0.2,0.3]])
#Plane_pos = numpy.vstack([Plane_pos,[0.5,0.4]])

#---reset sampled points and log flight
f = open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints.csv', 'wb')
f.write('0,0\n')   

f = open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints_log.csv', 'wb')
f.write('0,0\n')     
#-----------------------------------------------------------
        
        
start_time = time.time()

while True:
 


    with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/R_number.csv', 'rb') as f:
     reader = csv.reader(f,delimiter='\t')
     for row in reader:
         prev_iter = simulation_iter
         simulation_iter = int(row[0])
    
    if prev_iter != simulation_iter :
        
        
        #-----------Save old files
       


        shutil.copy2('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints_log.csv', 'C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints_log'+str(simulation_iter)+'.csv')
        
        shutil.copy2('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints.csv', 'C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints'+str(simulation_iter)+'.csv')
                 
        #----------------Write new plumebox
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
            
        #-----------------------------------
    
       # time.sleep(1)
        with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/R_nav_coordinates.csv', 'rb') as R_file:
            reader = csv.reader(R_file)
            A = []
            i_row = 0
            for row in reader:
                if i_row == 0:
                    A.append(row)
                    i_row+=1
                else:
                    A = numpy.vstack([A,row])
                    i_row+=1
    
        #=----------REINITIALISE AND RESEND FIRST WAYPOINT
        prev_wp_count = 0
        wp_count = 1
        if A[wp_count][0]:
            x = float(A[wp_count][0])
            y = float(A[wp_count][1])
            lat = float(plume_box[4][8]) + y*DeltaLat
            lng = float(plume_box[4][9]) + x*DeltaLong
            alt = 200
            msg = '|'+'alt'+'|'+str(alt)+'|'+'lat'+'|'+str(lat)+'|'+'lng'+'|'+str(lng)+'|'
            
            conn.send(msg)
            print msg
        #--------------------------------------
        #---reset sampled points and log flight
        f = open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints.csv', 'wb')
        f.write('0,0\n')   
        
        f = open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints_log.csv', 'wb')
        f.write('0,0\n')     
        Plane_pos = ['V1', 'V2']
        #-----------------------------------------------------------
            

        
        
    with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/R_nav_coordinates.csv', 'rb') as R_file:
        reader = csv.reader(R_file)
        A = []
        i_row = 0
        for row in reader:
            if i_row == 0:
                A.append(row)
                i_row+=1
            else:
                A = numpy.vstack([A,row])
                i_row+=1
   


    if wp_count >= (i_row -1) and i_row != 0:
        wp_count = i_row -1
        
        
    if wp_count > 9 and i_row > 2:
        wp_count = i_row - 1
    print 'Running 1'
    try:
        print 'Receiving Data'
        data = conn.recv(BUFFER_SIZE)
    except:
        print 'Trying to reconnect'
        conn, addr = s.accept()
        conn.settimeout(5.0)
        
    list = re.split('\|+',data)
    print 'Running 2'
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
            cur_time = time.time()
            if cur_y >= 0 and cur_x >= 0:
                with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints_log.csv', 'a') as Pl_file:
                        #writer = csv.writer(Pl_file)
                        #writer.writerows(cur_pos)
                        Pl_file.write("%f" % cur_x )
                        Pl_file.write(",%f\n" % cur_y)
                        Pl_file.close()
            if cur_y >= 0 and cur_x >= 0:            
                if float(cur_time - start_time) > 7 and grid_nav == 1:
                    start_time = cur_time
                    
                    Plane_pos = numpy.vstack([Plane_pos,cur_pos])
                    print 'Writing Currest Plane position'
                    with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints.csv', 'a') as Pl_file:
#                        writer = csv.writer(Pl_file)
#                        writer.writerows(Plane_pos)
                        Pl_file.write("%f" % cur_x )
                        Pl_file.write(",%f\n" % cur_y)
                        
                        Pl_file.close()
        elif item == "gndspeed":
            print "Groundspeed:", list[position+1]
            cur_gndspeed = list[position+1]
        elif item == "wpdst":
            print "Waypoint distance:", list[position+1]
            wp_dst = float(list[position+1])
         
            print 'Checking wpdst'
            if wp_dst < 120:
                if wp_count != prev_wp_count:
                    #start_time = cur_time
                    prev_wp_count = wp_count
                    #Plane_pos = numpy.vstack([Plane_pos,cur_pos])
                    print 'Writing Currest Plane position'
                    with open('C:/Users/sebas_000/Documents/Programming/Plane-SITL/Plane_flightpoints.csv', 'wb') as Pl_file:
                        writer = csv.writer(Pl_file)
                        writer.writerows(Plane_pos)
                        Pl_file.close()
                if A[wp_count][0]:
                    x = float(A[wp_count][0])
                    y = float(A[wp_count][1])
                    lat = float(plume_box[4][8]) + y*DeltaLat
                    lng = float(plume_box[4][9]) + x*DeltaLong
                    alt = 150
                    msg = '|'+'alt'+'|'+str(alt)+'|'+'lat'+'|'+str(lat)+'|'+'lng'+'|'+str(lng)+'|'
                    wp_count += 1
                    for i in range(1,4):
                        conn.send(msg)
                        data = conn.recv(BUFFER_SIZE)
                    
            
                
                
                
             
            conn.send(msg)
            print msg

conn.close()
#                        
#
#    
        

