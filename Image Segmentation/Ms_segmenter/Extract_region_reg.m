function [Boundary, Area] = Extract_region (Image_given, Min_area)
% Extract_region - given Initial_value (a pixel close to the actual
% boundary of a segment), and Image containing the segment,
% outputs the supposed boundary of the piece (not necessarily connected)
% by finding the connected component containing the given point first,
% and finding the perimeter of the piece second

[Rows_i, Cols_i] = size(Image_given);
Enclosing = zeros(Rows_i+2, Cols_i+2);
Enclosing(2:Rows_i+1, 2:Cols_i+1) = Image_given;
Area = bwarea(Enclosing);
if Area < Min_area
	Boundary = 0;
	return;
end
Boundary = bwperim(Enclosing);
[Rows, Cols] = find(Boundary);
Boundary = [Rows'; Cols'];
Boundary = Boundary-ones(size(Boundary));
