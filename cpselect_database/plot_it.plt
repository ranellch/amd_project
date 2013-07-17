set terminal png
set xlabel "Image Pairs"
unset key
set output "plot_x.png"
set ylabel "Pixels
set title "Difference in X-Values"
unset arrow
set arrow from 0,6.50249873171 to 40,6.50249873171 nohead lc rgb "red"
set arrow from 0,82.822209085 to 40,82.822209085 nohead lc rgb "green"
set arrow from 0,-69.8172116216 to 40,-69.8172116216 nohead lc rgb "green"
set yrange [-266.7366888:266.7366888]
plot "results.csv" using 1:2 with points lc rgb "blue"
set output "plot_y.png"
set ylabel "Pixels"
set title "Difference in Y-Values"
unset arrow
set arrow from 0,0.717241439024 to 40,0.717241439024 nohead lc rgb "red"
set arrow from 0,70.2562428536 to 40,70.2562428536 nohead lc rgb "green"
set arrow from 0,-68.8217599756 to 40,-68.8217599756 nohead lc rgb "green"
set yrange [-188.308314:188.308314]
plot "results.csv" using 1:3 with points lc rgb "blue"
set output "plot_theta.png"
set ylabel "Theta"
set title "Difference in Theta-Values"
unset arrow
set arrow from 0,-0.00270163414634 to 40,-0.00270163414634 nohead lc rgb "red"
set arrow from 0,0.0434356777564 to 40,0.0434356777564 nohead lc rgb "green"
set arrow from 0,-0.0488389460491 to 40,-0.0488389460491 nohead lc rgb "green"
set yrange [-0.1041888:0.1041888]
plot "results.csv" using 1:4 with points lc rgb "blue"
set output "plot_scale.png"
set ylabel "Scale"
set title "Difference in Scale-Values"
unset arrow
set arrow from 0,1.50975609756e-05 to 40,1.50975609756e-05 nohead lc rgb "red"
set arrow from 0,0.019888014775 to 40,0.019888014775 nohead lc rgb "green"
set arrow from 0,-0.0198578196531 to 40,-0.0198578196531 nohead lc rgb "green"
set yrange [-0.0210768:0.0210768]
plot "results.csv" using 1:5 with points lc rgb "blue"
set output "plot_time.png"
set ylabel "Time (sec)"
set title "Runtime for Pairs of Images"
unset arrow
set arrow from 0,377.600990854 to 40,377.600990854 nohead lc rgb "red"
set arrow from 0,743.413338043 to 40,743.413338043 nohead lc rgb "green"
set arrow from 0,11.788643664 to 40,11.788643664 nohead lc rgb "green"
set yrange [0:1044.99375]
plot "results.csv" using 1:6 with points lc rgb "blue"
