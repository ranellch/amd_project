import sys
import struct
import numpy as np

input_file = sys.argv[1]

f = open(input_file)

i = 0
columns_header = dict()
user_runs = dict()

x = []
yx = []
yy = []
ytheta = []
yscale = []
yrun = []
x_val = 0

for line in f:
    splitit = line.split(',')
    if i > 0:
        #Get the username, time1 and time2 of the current image pair
        usern = splitit[columns_header['id']]
        time1 = int(splitit[columns_header['time1']])
        time2 = int(splitit[columns_header['time2']])
		
		#Make sure that alaways time1 < time2
        if time2 < time1:
            temp = time1
            time1 = time2
            time2 = temp
        
        #Build the data struct that keeps track of runs already done
        if usern not in user_runs:
            user_runs[usern] = dict()
        if time1 not in user_runs[usern]:
            user_runs[usern][time1] = dict()
        if time2 not in user_runs[usern][time1]:
            user_runs[usern][time1][time2] = 0
        
        #Get the runs that are note already done by the user
        if user_runs[usern][time1][time2] == 0:
            #Get the change from one image to another
            x1 = float(splitit[columns_header['x1']])
            y1 = float(splitit[columns_header['y1']])
            theta1 = float(splitit[columns_header['theta1']])
            scale1 = float(splitit[columns_header['scale1']])
            
            #Get the change from one image to another
            x2 = float(splitit[columns_header['x2']])
            y2 = float(splitit[columns_header['y2']])
            theta2 = float(splitit[columns_header['theta2']])
            scale2 = float(splitit[columns_header['scale2']])

			#Runtime
            runtime = float(splitit[columns_header['runtime']])
			
            #Get the difference between two types of images
            xdiff = x2 - x1
            ydiff = y2 - y1
            thetadiff = theta2 - theta1
            scalediff = scale2 - scale1
			
            #Write results of this analysis
            yx.append(xdiff)
            yy.append(ydiff)
            ytheta.append(thetadiff)
            yscale.append(scalediff)
            yrun.append(runtime)
            x.append(x_val)
            x_val = x_val + 1
            
            #For the results mark this pair as run
            user_runs[usern][time1][time2] = 1
    else:
        #Get the header from the file
        j = 0
        for col in splitit:
            columns_header[col.replace(' ','').replace('\n','')] = j
            j=j+1
    i=i+1    

f.close()

#Build y max array based upon lists of values
y_max = []
y_max.append(max(yx))
y_max.append(max(yy))
y_max.append(max(ytheta))
y_max.append(max(yscale))
y_max.append(max(yrun))

y_mean = []
y_mean.append(np.mean(yx))
y_mean.append(np.mean(yy))
y_mean.append(np.mean(ytheta))
y_mean.append(np.mean(yscale))
y_mean.append(np.mean(yrun))

y_stddev = []
y_stddev.append(np.std(yx) * 2)
y_stddev.append(np.std(yy) * 2)
y_stddev.append(np.std(ytheta) * 2)
y_stddev.append(np.std(yscale) * 2)
y_stddev.append(np.std(yrun) * 2)


#Write the results of the difference between image sets
resultscsv = 'results.csv'
f=open(resultscsv, 'w')
i = 0
for x_val in x:
    f.write(str(x_val))
    f.write('\t')
    f.write(str(yx[i]))
    f.write('\t')
    f.write(str(yy[i]))
    f.write('\t')
    f.write(str(ytheta[i]))
    f.write('\t')
    f.write(str(yscale[i]))
    f.write('\t')
    f.write(str(yrun[i]))
    f.write('\n')
    i=i+1
f.close()

#Calculate the max y value change
for i in range(0, len(y_max)):
    y_max[i] *= 1.2

#Write the gnu plot script to plot this
line = 'set terminal png\n'
line += 'set xlabel "Image Pairs"\n'
line += 'unset key\n'
line += 'set output "plot_x.png"\n'
line += 'set ylabel "Pixels\n'
line += 'set title "Difference in X-Values"\n'
line += 'unset arrow\n'
line += 'set arrow from 0,' + str(y_mean[0]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[0]) + ' nohead lc rgb "red"\n'
line += 'set arrow from 0,' + str(y_mean[0] + y_stddev[0]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[0] + y_stddev[0]) + ' nohead lc rgb "green"\n'
line += 'set arrow from 0,' + str(y_mean[0] - y_stddev[0]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[0] - y_stddev[0]) + ' nohead lc rgb "green"\n'
line += 'set yrange [' + str(-1 * y_max[0]) + ':' + str(y_max[0]) + ']\n'
line += 'plot "' + resultscsv + '" using 1:2 with points lc rgb "blue"\n'
line += 'set output "plot_y.png"\n'
line += 'set ylabel "Pixels"\n'
line += 'set title "Difference in Y-Values"\n'
line += 'unset arrow\n'
line += 'set arrow from 0,' + str(y_mean[1]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[1]) + ' nohead lc rgb "red"\n'
line += 'set arrow from 0,' + str(y_mean[1] + y_stddev[1]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[1] + y_stddev[1]) + ' nohead lc rgb "green"\n'
line += 'set arrow from 0,' + str(y_mean[1] - y_stddev[1]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[1] - y_stddev[1]) + ' nohead lc rgb "green"\n'
line += 'set yrange [' + str(-1 * y_max[1]) + ':' + str(y_max[1]) + ']\n'
line += 'plot "' + resultscsv + '" using 1:3 with points lc rgb "blue"\n'
line += 'set output "plot_theta.png"\n'
line += 'set ylabel "Theta"\n'
line += 'set title "Difference in Theta-Values"\n'
line += 'unset arrow\n'
line += 'set arrow from 0,' + str(y_mean[2]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[2]) + ' nohead lc rgb "red"\n'
line += 'set arrow from 0,' + str(y_mean[2] + y_stddev[2]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[2] + y_stddev[2]) + ' nohead lc rgb "green"\n'
line += 'set arrow from 0,' + str(y_mean[2] - y_stddev[2]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[2] - y_stddev[2]) + ' nohead lc rgb "green"\n'
line += 'set yrange [' + str(-1 * y_max[2]) + ':' + str(y_max[2]) + ']\n'
line += 'plot "' + resultscsv + '" using 1:4 with points lc rgb "blue"\n'
line += 'set output "plot_scale.png"\n'
line += 'set ylabel "Scale"\n'
line += 'set title "Difference in Scale-Values"\n'
line += 'unset arrow\n'
line += 'set arrow from 0,' + str(y_mean[3]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[3]) + ' nohead lc rgb "red"\n'
line += 'set arrow from 0,' + str(y_mean[3] + y_stddev[3]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[3] + y_stddev[3]) + ' nohead lc rgb "green"\n'
line += 'set arrow from 0,' + str(y_mean[3] - y_stddev[3]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[3] - y_stddev[3]) + ' nohead lc rgb "green"\n'
line += 'set yrange [' + str(-1 * y_max[3]) + ':' + str(y_max[3]) + ']\n'
line += 'plot "' + resultscsv + '" using 1:5 with points lc rgb "blue"\n'
line += 'set output "plot_time.png"\n'
line += 'set ylabel "Time (sec)"\n'
line += 'set title "Runtime for Pairs of Images"\n'
line += 'unset arrow\n'
line += 'set arrow from 0,' + str(y_mean[4]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[4]) + ' nohead lc rgb "red"\n'
line += 'set arrow from 0,' + str(y_mean[4] + y_stddev[4]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[4] + y_stddev[4]) + ' nohead lc rgb "green"\n'
line += 'set arrow from 0,' + str(y_mean[4] - y_stddev[4]) + ' to ' + str(x[len(x)-1]) + ',' + str(y_mean[4] - y_stddev[4]) + ' nohead lc rgb "green"\n'
line += 'set yrange [0:' + str(y_max[4]) + ']\n'
line += 'plot "' + resultscsv + '" using 1:6 with points lc rgb "blue"\n'

f=open('plot_it.plt', 'w') 
f.write(line)
f.close()
