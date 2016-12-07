function [px, py] = trgPointCoord(p, t, refcoord)
  % Given a 2-dim vector refcoord for the reference coordinate,
  % compute the actual coordinate of points in alltriangle correspond to
  % this reference coordinate. Here refcoord contains
  %     (x, y)
  % On the reference triangle, (x, y) are
  %         identical to (\lambda_2, \lambda_3) in the
  %         barycentric coordinate, and \lambda_1 = 1-x-y
  %
  % The output is stored in two
  % row vectors, px for x-coordinate and py for y-coordinate.
  % Both are ordered according to the triangle defined in t.
  %
  % Example:
  %  [px, py] = trgPointCoord(p, t, [1/3, 1/3]); 
  %                               returns the center of triangles
  
  px = (1-refcoord(1)-refcoord(2)) * p(1, t(1,:)) + ...
      refcoord(1) * p(1, t(2,:)) + refcoord(2) * p(1, t(3,:));
  py = (1-refcoord(1)-refcoord(2)) * p(2, t(1,:)) + ...
      refcoord(1) * p(2, t(2,:)) + refcoord(2) * p(2, t(3,:));