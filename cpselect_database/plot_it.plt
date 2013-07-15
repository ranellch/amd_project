set terminal png
set xlabel "Image Pairs"
unset key
set output "plot_x.png"
set ylabel "Pixels
set title "Difference in X-Values"
set yrange [-266.7366888:266.7366888]
plot "results.csv" using 1:2 with points
set output "plot_y.png"
set ylabel "Pixels"
set title "Difference in Y-Values"
set yrange [-188.308314:188.308314]
plot "results.csv" using 1:3 with points
set output "plot_theta.png"
set ylabel "Theta"
set title "Difference in Theta-Values"
set yrange [-0.1041888:0.1041888]
plot "results.csv" using 1:4 with points
set output "plot_scale.png"
set ylabel "Scale"
set title "Difference in Scale-Values"
set yrange [-0.0576408:0.0576408]
plot "results.csv" using 1:5 with points
