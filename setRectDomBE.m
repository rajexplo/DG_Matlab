function [be, beSegN, beOrient] = setRectDomBE(m, n)
% Set Boundary edge for rectangular domains divided into m*n.
% Not the boundary edge is the same for qudrilateral and triangular meshes.
% The output can be used directly as meshData.BE, meshData.BESegN,
% and meshData.BEOrient.

  be = zeros(2, 2*(m+n));
  beSegN = zeros(1, 2*(m+n));
  beOrient = zeros(1, 2*(m+n));
  
  % bottom edge
  be(:, 1:m) = [1:m; 2:m+1];
  beSegN(:, 1:m) = ones(1,m);
  beOrient(:, 1:m) = ones(1,m);
  % right edge
  be(:, m+1:m+n) = [m+1:m+1:n*(m+1); 2*(m+1):m+1:(n+1)*(m+1)];
  beSegN(:, m+1:m+n) = 2*ones(1,n);
  beOrient(:, m+1:m+n) = ones(1,n);
  % top edge
  be(:, m+n+1:m+n+m) = [(n+1)*(m+1):-1:n*(m+1)+2; ...
                                 (n+1)*(m+1)-1:-1:n*(m+1)+1];
  beSegN(:, m+n+1:m+n+m) = 3*ones(1,m);
  beOrient(:, m+n+1:m+n+m) = ones(1,m);
  % left edge
  be(:, m+n+m+1:m+n+m+n) = [n*(m+1)+1:-m-1:m+2; ...
                                 (n-1)*(m+1)+1:-m-1:1];
  beSegN(:, m+n+m+1:m+n+m+n) = 4*ones(1,n);
  beOrient(:, m+n+m+1:m+n+m+n) = ones(1,n);