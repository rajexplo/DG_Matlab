function [a] = trgArea(p, t)
% Computes the area of all triangles in a triangular mesh.
% When ( meshData.elementType == 'triangular' )
% p, t should be meshData.P, meshData.T (see meshInfo.m for details).
%
% It returns a row vector A of dimension = meshData.nT,
% which contains the areas of each triangle.

  % indices of points
  p1Ind = t(1,:);
  p2Ind = t(2,:);
  p3Ind = t(3,:);
  
  % x and y components of edge12 and edge13
  % Example of edge naming convention: 
  %     edge23x means x component of edge from p2 to p3
  %     edge32y means y component of edge from p3 to p2
  edge12x = p(1,p2Ind) - p(1,p1Ind);
  edge12y = p(2,p2Ind) - p(2,p1Ind);
  edge13x = p(1,p3Ind) - p(1,p1Ind);
  edge13y = p(2,p3Ind) - p(2,p1Ind);
  
  % area 
  a = (1/2)*(edge12x.*edge13y - edge12y.*edge13x);