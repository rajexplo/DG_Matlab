function [edgeL] = edgeLength(p,e)
  % Compute length of edges.
  % It returns a row vector of dimension meshData.nE
 
  edgeL = sqrt(sum((p(:,e(2,:)) - p(:,e(1,:))).^2,1));