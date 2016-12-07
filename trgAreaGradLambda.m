function [a, g1x, g1y, g2x, g2y, g3x, g3y] = trgAreaGradLambda(p,t)
% Computes the area of triangles (see trgArea.m for information on a)
% and \grad g(i), where g1, g2, g3 are the nodal basis functions of
% P1 (in other words, the three barycentric coordinates.)
% Each output variable is a row vector of dimension = meshData.nT

  % indices of points
  p1Ind = t(1,:);
  p2Ind = t(2,:);
  p3Ind = t(3,:);
  
  % x and y components of edges.
  % Example of edge naming convention: 
  %     edge23x means x component of edge from p2 to p3
  %     edge32y means y component of edge from p3 to p2
  edge12x = p(1,p2Ind) - p(1,p1Ind);
  edge21y = p(2,p1Ind) - p(2,p2Ind);
  edge31x = p(1,p1Ind) - p(1,p3Ind);
  edge13y = p(2,p3Ind) - p(2,p1Ind);
  edge23x = p(1,p3Ind) - p(1,p2Ind);
  edge32y = p(2,p2Ind) - p(2,p3Ind);
  
  % 2|T|
  a = edge12x.*edge13y - edge21y.*edge31x;
  
  % gradient terms
  g1x = edge32y./a;
  g1y = edge23x./a;
  g2x = edge13y./a;
  g2y = edge31x./a;
  g3x = edge21y./a;
  g3y = edge12x./a;
  
  % Compute |T|
  a = (1/2)*a;