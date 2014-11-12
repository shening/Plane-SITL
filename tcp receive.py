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


MPmsg = '1'
arrays = []
f = open('C:\Users\sebas_000\Documents\Python Workspace\Mission Planner\WP.txt')
parser = csv.reader(f, delimiter='\t')
i = 0
  
for row in parser:
    if i > 1:
        print row
        arrays = numpy.vstack([arrays, row])
    elif i == 1:
        arrays.append(row)
    i+=1
    

conn, addr = s.accept()
print 'Connection address:', addr


conn.settimeout(5.0)



i = 1
lat = arrays[i][8]
lng = arrays[i][9]
alt = arrays[i][10]
msg = '|'+'alt'+'|'+alt+'|'+'lat'+'|'+lat+'|'+'lng'+'|'+lng+'|'
i=i+1
conn.send(msg)
time_count = 0


while True:
    
#    try:
#        conn, addr = s.accept()
#        print 'Re-Connection address:', addr
#    finally:
#        print 'Re-connect fail'
    
    ##if not data: break
    ##print "received data:", data
    
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
        elif item == "heading":
            print "Heading:", list[position+1]
        elif item == "lat":
            print "Latitude:", list[position+1]
        elif item == "lng":
            print "Longitude:", list[position+1]
        elif item == "gndspeed":
            print "Groundspeed:", list[position+1]
        elif item == "wpdst":
            print "Waypoint distance:", list[position+1]
            wp_dst = float(list[position+1])
            time_count = time_count + 1
            print 'Checking wpdst'
            if wp_dst < 100:
                lat = arrays[i][8]
                lng = arrays[i][9]
                alt = arrays[i][10]
                msg = '|'+'alt'+'|'+alt+'|'+'lat'+'|'+lat+'|'+'lng'+'|'+lng+'|'
                i +=1 
                print i
             
            conn.send(msg)

conn.close()
#                        
#
#    
        

