set terminal png
set xlabel "Image Pairs"
unset key
set output "plot_x.png"
set ylabel "Pixels"
set title "Difference in X-Values - stddev: 53.958120025"
unset arrow
set arrow from 0,-0.100172223684 to 75,-0.100172223684 nohead lc rgb "red"
set arrow from 0,107.816067826 to 75,107.816067826 nohead lc rgb "green"
set arrow from 0,-108.016412274 to 75,-108.016412274 nohead lc rgb "green"
set yrange [-271.409994:271.409994]
plot "results.csv" using 1:2 with points lc rgb "blue"
set output "plot_y.png"
set ylabel "Pixels"
set title "Difference in Y-Values - stddev: 67.8677980745"
unset arrow
set arrow from 0,-15.1116477368 to 75,-15.1116477368 nohead lc rgb "red"
set arrow from 0,120.623948412 to 75,120.623948412 nohead lc rgb "green"
set arrow from 0,-150.847243886 to 75,-150.847243886 nohead lc rgb "green"
set yrange [-193.7378604:193.7378604]
plot "results.csv" using 1:3 with points lc rgb "blue"
set output "plot_theta.png"
set ylabel "Theta"
set title "Difference in Theta-Values - stddev: 0.0530542176079"
unset arrow
set arrow from 0,-0.00625765789474 to 75,-0.00625765789474 nohead lc rgb "red"
set arrow from 0,0.0998507773211 to 75,0.0998507773211 nohead lc rgb "green"
set arrow from 0,-0.112366093111 to 75,-0.112366093111 nohead lc rgb "green"
set yrange [-0.2200464:0.2200464]
plot "results.csv" using 1:4 with points lc rgb "blue"
set output "plot_scale.png"
set ylabel "Scale"
set title "Difference in Scale-Values - stddev: 0.0476450841124"
unset arrow
set arrow from 0,-0.0131167631579 to 75,-0.0131167631579 nohead lc rgb "red"
set arrow from 0,0.0821734050669 to 75,0.0821734050669 nohead lc rgb "green"
set arrow from 0,-0.108406931383 to 75,-0.108406931383 nohead lc rgb "green"
set yrange [-0.2338428:0.2338428]
plot "results.csv" using 1:5 with points lc rgb "blue"
set output "plot_time.png"
set ylabel "Time (sec)"
set title "Runtime for Pairs of Images - stddev: 462.467309603"
unset arrow
set arrow from 0,640.772121711 to 75,640.772121711 nohead lc rgb "red"
set arrow from 0,1565.70674092 to 75,1565.70674092 nohead lc rgb "green"
set arrow from 0,-284.162497496 to 75,-284.162497496 nohead lc rgb "green"
set yrange [0:2404.836]
plot "results.csv" using 1:6 with points lc rgb "blue"
