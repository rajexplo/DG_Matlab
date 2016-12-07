function [t, n] = edgeDirection(p, e)
  % Compute edge length, unit tangential vectors t, and unit normal vectors n.
  % The tangential vector is from starting point to ending point.
  % The normal vector is pointing to the right side of the edge.
  % It returns edgeL, a row vector of dimension meshData.nE,
  % t, n, two 2-by-meshData.nE matrices.
  
  edgeVec = p(:,e(2,:)) - p(:,e(1,:));
  edgeL = sqrt(sum(edgeVec.^2,1));
  t = edgeVec./[edgeL; edgeL];
  n = [t(2,:); -t(1,:)];