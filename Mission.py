import httplib
import recv1       #receive info about plane1
import waypoint    #send plane 1
import time        #sleep inbetween waypoints
from autoway import sendPoints, calculate        #send plane 2


RANGE = 1600   #range of XBee in meters

#---------Make function, read calibration box------
f = open('C:\Users\sebas_000\Documents\HIL Sebastian\pythonConfig.txt')
lines = f.readlines()
msg = lines[0].split(",")
DeltaLat = float(msg[2]) - float(msg[0])
DeltaLong = float(msg[7]) - float(msg[1])
x = 0.5
y = 0.5
check = 0

f.close()

f = open('C:\Users\sebas_000\Documents\pythonwrite','w')              
a = 1;
f.write("%s\n" % (a))            
f.close() # you can omit in most cases as the destructor will call if
#------------------------




#mission way points for plane 1
wayPoints = [(36.9930029,-121.9824725, 1000), (36.9926301,-121.9805145, 1000), (36.9922359,-121.9784546, 1000)]
             
home = (34.630600,-118.112854, 773.239990)               #home location

sendPoints(home, wayPoints)                             #give plane 2, the locations

#send plane one to it's first way point
#p = wayPoints[0]
#waypoint.send(p[0], p[1], p[2])

#connect to get information for plane one
recv1.openConnection()

hDist=0
#while hDist <= (.8*RANGE) :  #while plane1 is still in range, wait
    #hDist,w = recv1.getDist()

#calculate()     #send plane two to be a relay

#go to the different way points 3 times
#for _ in range(1,3):
while 1:
    #for p in wayPoints:
        done = False
        time.sleep(2)       #give time for waypoint distance to update
        if a >= 8:
            a = 0;

        while done==False:            #while not to the way point, wait
            h, wpDist = recv1.getDist()
            #print wpDist
            if wpDist <= 80:        #once close enough send to the next way point
                print "Sending way point."
                a = a+1
                f = open('C:\Users\sebas_000\Documents\pythonwrite','w')
                f.write("%s\n" % (a))
                f.close() # you can omit in most cases as the destructor will call if
                
                time.sleep(2)
                
                
                
                while check != a:
                    time.sleep(.1)
                    h, wpDist = recv1.getDist()
                    f = open('C:\Users\sebas_000\Documents\dataTest')
                    try:
                            lines = f.readlines()
                            Rcoord = lines[0].split(",")
                            x = float(Rcoord[0])
                            y = float(Rcoord[1])
                            check = float(Rcoord[2])
                    except:
                            pass
                    
                
                Lat = float(msg[0]) + y*DeltaLat
                Long = float(msg[1]) + x*DeltaLong
                print Lat
                print Long
                print a
                waypoint.send(Lat, Long, 1000)
                time.sleep(1)

                done = True         #move on to the next way point
                
#recv1.closeConnection()
