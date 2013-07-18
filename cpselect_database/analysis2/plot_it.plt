set terminal png
set xlabel "Image Pairs"
unset key
set output "plot_x.png"
set ylabel "Pixels"
set title "Difference in X-Values - stddev: 37.6507909086"
unset arrow
set arrow from 0,7.94314665854 to 40,7.94314665854 nohead lc rgb "red"
set arrow from 0,83.2447284757 to 40,83.2447284757 nohead lc rgb "green"
set arrow from 0,-67.3584351586 to 40,-67.3584351586 nohead lc rgb "green"
set yrange [-267.0814752:267.0814752]
plot "results.csv" using 1:2 with points lc rgb "blue"
set output "plot_y.png"
set ylabel "Pixels"
set title "Difference in Y-Values - stddev: 33.0254563234"
unset arrow
set arrow from 0,-1.34196565854 to 40,-1.34196565854 nohead lc rgb "red"
set arrow from 0,64.7089469882 to 40,64.7089469882 nohead lc rgb "green"
set arrow from 0,-67.3928783053 to 40,-67.3928783053 nohead lc rgb "green"
set yrange [-192.8416104:192.8416104]
plot "results.csv" using 1:3 with points lc rgb "blue"
set output "plot_theta.png"
set ylabel "Theta"
set title "Difference in Theta-Values - stddev: 0.0183140351938"
unset arrow
set arrow from 0,-0.00519646341463 to 40,-0.00519646341463 nohead lc rgb "red"
set arrow from 0,0.0314316069729 to 40,0.0314316069729 nohead lc rgb "green"
set arrow from 0,-0.0418245338021 to 40,-0.0418245338021 nohead lc rgb "green"
set yrange [-0.0999204:0.0999204]
plot "results.csv" using 1:4 with points lc rgb "blue"
set output "plot_scale.png"
set ylabel "Scale"
set title "Difference in Scale-Values - stddev: 0.00988593925581"
unset arrow
set arrow from 0,0.000227390243902 to 40,0.000227390243902 nohead lc rgb "red"
set arrow from 0,0.0199992687555 to 40,0.0199992687555 nohead lc rgb "green"
set arrow from 0,-0.0195444882677 to 40,-0.0195444882677 nohead lc rgb "green"
set yrange [-0.0175224:0.0175224]
plot "results.csv" using 1:5 with points lc rgb "blue"
set output "plot_time.png"
set ylabel "Time (sec)"
set title "Runtime for Pairs of Images - stddev: 160.388421467"
unset arrow
set arrow from 0,327.483612805 to 40,327.483612805 nohead lc rgb "red"
set arrow from 0,648.260455739 to 40,648.260455739 nohead lc rgb "green"
set arrow from 0,6.70676987102 to 40,6.70676987102 nohead lc rgb "green"
set yrange [0:846.7875]
plot "results.csv" using 1:6 with points lc rgb "blue"
