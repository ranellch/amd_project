function Vertex_coords = Vertex_at (Region)
% tells where on the plane to place the corresponding to the region vertex
% will assume for the time being that regions are represented as 
% objects with various characteristics - Boundary, Matrix, Inner pt, etc.
% this function could be overwritten, but should be based on the same props.

Vertex_coords = round(mean(Region.Boundary, 2));  % take the gravicenter
