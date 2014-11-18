#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      AUSTIN
#
# Created:     13/03/2013
# Copyright:   (c) AUSTIN 2013
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import sys
import socket
import re
import sys
import clr
import time
import MissionPlanner #import *
clr.AddReference("MissionPlanner.Utilities") # includes the Utilities class


TCP_IP = '127.0.0.1'
TCP_PORT = 5030
BUFFER_SIZE = 1024


s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.connect((TCP_IP, TCP_PORT))





a="alt"
b="heading"
c="lat"
d="lng"
e="gndspeed"


Script.SendRC(3,1500,True)
Script.Sleep(4000)
Script.SendRC(3,1000,True)

init_alt = 0
init_lng = 0
init_lat = 0
item = MissionPlanner.Utilities.Locationwp() # creating waypoint
lat = 39.343674                                           # Latitude value
lng = -86.029741                                         # Longitude value
alt = 45.720000 
while True:
     
	 cur_alt = str(cs.alt)
	 cur_heading = str(cs.yaw)
	 cur_lat = str("%.12f"%cs.lat)
	 cur_lng = str("%.12f"%cs.lng)
	 cur_gndspeed = str(cs.groundspeed)
	 cur_wpdist = str(cs.wp_dist)
	 

	 msg = '|'+'alt'+'|'+cur_alt+'|'+'heading'+'|'+cur_heading+'|'+'lat'+'|'+cur_lat+'|'+'lng'+'|'+cur_lng+'|'+'gndspeed'+'|'+cur_gndspeed+'|'+'wpdst'+'|'+cur_wpdist+'|'
	 s.send(msg)
	 recdata = s.recv(100)
	 list = re.split('\|+',recdata)
	 for position, item in enumerate(list):
			if item == "alt":
				print "Altitude:", list[position+1]
				alt = float(list[position+1])
				print alt
				init_alt = 1
			elif item == "lat":
				print "Latitude:", list[position+1]
				lat = float(list[position+1])
				init_lat = 1
				print lat
			elif item == "lng":
				print "Longitude:", list[position+1]
				lng = float(list[position+1])
				init_lng = 1
				print lng
	 
	 
	 if (init_lat == 1 and init_alt == 1 and init_lng == 1):
		 item = MissionPlanner.Utilities.Locationwp() # creating waypoint

		 MissionPlanner.Utilities.Locationwp.lat.SetValue(item,lat)     # sets latitude
		 MissionPlanner.Utilities.Locationwp.lng.SetValue(item,lng)   # sets longitude
		 MissionPlanner.Utilities.Locationwp.alt.SetValue(item,alt)     # sets altitude 
		 init_alt = 0
		 init_lat = 0
		 init_lng = 0
		 # MissionPlanner.Utilities.Locationwp.lat.SetValue(item,cmd_lat)     # sets latitude
		 # MissionPlanner.Utilities.Locationwp.lng.SetValue(item,cmd_lng)   # sets longitude
		 # MissionPlanner.Utilities.Locationwp.alt.SetValue(item,cmd_alt)     # sets altitude
		 

		 MAV.setGuidedModeWP(item) 
		 
	 Script.Sleep(200)

