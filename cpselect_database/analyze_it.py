import sys
import struct

input_file = sys.argv[1]

f = open(input_file)

i = 0
columns_header = dict()
user_runs = dict()

x = []
y = []
y_max = [0,0,0,0]
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

            #Get the difference between two types of images
            xdiff = x2 - x1
            ydiff = y2 - y1
            thetadiff = theta2 - theta1
            scalediff = scale2 - scale1
			
            #Write results of this analysis
            y.append([])
            y[x_val].append(xdiff)
            y[x_val].append(ydiff)
            y[x_val].append(thetadiff)
            y[x_val].append(scalediff)
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

#Write the results of the difference between image sets
resultscsv = 'results.csv'
f=open(resultscsv, 'w')
i=0
for y_val in y:
    f.write(str(x[i]))
    j=0
    for col in y_val:
        f.write('\t' + str(col))
        if y_max[j] < abs(col):
            y_max[j] = abs(col)
        j=j+1
    f.write('\n')
    i=i+1
f.close()

#Calculate the max y value change
for i in range(0, len(y_max)):
    y_max[i] *= 1.2

#Write the gnu plot script to plot this
f=open('plot_it.plt', 'w')
f.write('set terminal png\n')
f.write('set xlabel "Image Pairs"\n')
f.write('unset key\n')
f.write('set output "plot_x.png"\n')
f.write('set ylabel "Pixels\n')
f.write('set title "Difference in X-Values"\n')
f.write('set yrange [' + str(-1 * y_max[0]) + ':' + str(y_max[0]) + ']\n')
f.write('plot "' + resultscsv + '" using 1:2 with points\n')
f.write('set output "plot_y.png"\n')
f.write('set ylabel "Pixels"\n')
f.write('set title "Difference in Y-Values"\n')
f.write('set yrange [' + str(-1 * y_max[1]) + ':' + str(y_max[1]) + ']\n')
f.write('plot "' + resultscsv + '" using 1:3 with points\n')
f.write('set output "plot_theta.png"\n')
f.write('set ylabel "Theta"\n')
f.write('set title "Difference in Theta-Values"\n')
f.write('set yrange [' + str(-1 * y_max[2]) + ':' + str(y_max[2]) + ']\n')
f.write('plot "' + resultscsv + '" using 1:4 with points\n')
f.write('set output "plot_scale.png"\n')
f.write('set ylabel "Scale"\n')
f.write('set title "Difference in Scale-Values"\n')
f.write('set yrange [' + str(-1 * y_max[3]) + ':' + str(y_max[3]) + ']\n')
f.write('plot "' + resultscsv + '" using 1:5 with points\n')
f.close()
