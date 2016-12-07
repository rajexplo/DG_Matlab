function [p] = setRectDomPJiggle(a, b, c, d, m, n, opt)
% Set points for rectangular domain (a,b)*(c, d) partitioned into
% m*n subdivisions, with jiggle points.
% 0<=opt<=1 is the jiggle size.
% The output p can be used as meshData.P directly
% for rectangular meshes or triangular meshes (type '\', '/').
% For triangular meshes of type 'x', an extra center point need to be 
% added after calling setRectDomP.

  hx = (b-a)/m; 
  hy = (d-c)/n;
  p = zeros(2, (m+1)*(n+1));
  p(1,:) = repmat(a:hx:b, 1, n+1);
  p(2,:) = reshape(repmat(c:hy:d,m+1,1),1,(m+1)*(n+1));  
  % jiggle
  opt = max(min(opt,1),0);
  twistx = rand(n+1,m+1)*0.4*hx*opt - 0.2*hx*opt;
  twisty = rand(n+1,m+1)*0.4*hy*opt - 0.2*hy*opt;
  twistx(:, [1, end]) = 0;
  twisty([1, end], :) = 0;
  p(1,:) = p(1,:) + reshape(twistx', 1, (m+1)*(n+1));
  p(2,:) = p(2,:) + reshape(twisty', 1, (m+1)*(n+1));