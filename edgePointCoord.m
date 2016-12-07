function [px, py] = edgePointCoord(p, e, refcoord)
  % Given a reference coordinate 0<=refcoord<=1,
  % compute the actual coordinate of points on all edges with coordinate
  %   pStart + refcoord * (pEnd - pStart)
  %
  % The output is stored in two
  % row vectors, px for x-coordinate and py for y-coordinate.
  % Both are ordered according to the edges defined in e.
  %
  % Example:
  %   [px, py] = edgePointCoord(p, e, 0.5);  returns the center of edges
  
  px = (1-refcoord)*p(1, e(1, :)) + refcoord*p(1, e(2, :));
  py = (1-refcoord)*p(2, e(1, :)) + refcoord*p(2, e(2, :));