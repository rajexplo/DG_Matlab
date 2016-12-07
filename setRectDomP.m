function [p] = setRectDomP(a, b, c, d, m, n)
% Set points for rectangular domain (a,b)*(c, d) partitioned into
% m*n subdivisions.
% The output p can be used as meshData.P directly
% for rectangular meshes or triangular meshes (type '\', '/').
% For triangular meshes of type 'x', an extra center point need to be 
% added after calling setRectDomP.

  hx = (b-a)/m; 
  hy = (d-c)/n;
  p = zeros(2, (m+1)*(n+1));
  p(1,:) = repmat(a:hx:b, 1, n+1);
  p(2,:) = reshape(repmat(c:hy:d,m+1,1),1,(m+1)*(n+1));  