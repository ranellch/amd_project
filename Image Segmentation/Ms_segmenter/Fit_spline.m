function Dense_pts = Fit_spline (Pts)

Xdata = Pts(1, :);
Ydata = Pts(2, :);

% making splines separately for X and Y, but with common parameter
Length = 0;
Param(1) = Length;
for i=1:length(Xdata)-1
	Length = Length + norm(Pts(:, i+1) - Pts(:, i));
	Param(i+1) = Length;
end

% sampling at a dense set of points
Gridpts = [min(Param):0.1:max(Param)];
Xspline = round(spline(Param, Xdata, Gridpts));
Yspline = round(spline(Param, Ydata, Gridpts));

% if not sufficiently dense, adjusting those
k = 0;  Dense_pts = zeros(2, 0);
for i=1:length(Xspline)-1
	if max(abs(Xspline(i+1)-Xspline(i)), abs(Yspline(i+1)-Yspline(i))) > 1
		for j=0:abs(Xspline(i+1)-Xspline(i))
			k = k+1;
			Dense_pts(:, k) = [Xspline(i) + j*sign(Xspline(i+1)-Xspline(i)); ...
				Yspline(i)];
		end
		for j=0:abs(Yspline(i+1)-Yspline(i))
			k = k+1;
			Dense_pts(:, k) = [Xspline(i+1); ...
				Yspline(i) + j*sign(Yspline(i+1)-Yspline(i))];
		end
	 else
	 	k = k+1;
	 	Dense_pts(:, k) = [Xspline(i); Yspline(i)];
	end
end
