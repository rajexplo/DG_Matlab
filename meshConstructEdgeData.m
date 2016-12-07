function [meshData] = meshConstructEdgeData (meshData)
%
% generate edge related data structures, namely
%
%   E, T2E, E2T, ELInd, E2BE, BE2E
%
% Remark: meshConstructEdgeData resets BE so that they start from
% points with smaller indices. In this case, both BE2E and E2BE are 
% nonnegative.

  % Sort BE start and ending points by the point index
  [meshData.BE,tempI] = sort(meshData.BE);
  ind = ( diff(tempI,1,1)==-1 );  % indices of edges that has been flipped
  meshData.BEOrient(ind) = -meshData.BEOrient(ind);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Part 1: Creat tables E, T2E, E2T and ELInd
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Sort internal halfedges so that all starts from the vertex with smaller
  % index. Total nHalfEdges = 3*nT or 4*nT depending on mesh types.
  % Note that some of the halfedges are dummies that connect vertex 0 to 0.
  if strcmp(meshData.elementType,'quadrilateral')
    maxTn = 4;
  else
    maxTn = 3;
  end
  halfedges = zeros(2, maxTn*meshData.nT);
  for i=1:(maxTn-1)
    halfedges(:,((i-1)*meshData.nT+1):(i*meshData.nT)) = meshData.T([i, i+1],:);
  end
  i = maxTn;
  halfedges(:,((i-1)*meshData.nT+1):(i*meshData.nT)) = meshData.T([i,1],:);
  
  % e (2-by-nHalfedges)    -- sorted halfedge
  % flag (1-by-nHalfedges) -- orientation (1 or -1) of the halfedge in edge  
  [e, flag] = sort(halfedges);  
  flag = diff(flag,1,1);
  
  % Combine two opposite halfedges to get the unique edge.
  % e (nEdges-by-2)     -- stores the unique edge.
  % J (nHalfEdges-by-1) -- stores the halfedge-to-edge map
  [e, temp, J] = unique(e', 'rows');  
  meshData.E = e';
  [temp,meshData.nE] = size(meshData.E);
  
  % Then flag'.*J gives the halfedge-to-orientedEdge map.
  % This helps to generate T2E by triangle->halfedge->orientedEdge
  meshData.T2E = reshape(flag'.*J, meshData.nT, maxTn)';

  % Generate E2T. 
  % For boundary edges, either left or right triangle = 0.
  % T (1-by-nHalfEdges) -- stores indices of associated triangles
  %                        for each halfedge.
  meshData.E2T = zeros(2, meshData.nE);
  T = repmat(1:meshData.nT, 1, maxTn);
  % Left triangle index.
  lind = ( flag==1 );
  meshData.E2T(1,J(lind)) = T(lind);
  % Right triangle index.
  rind = ( flag==-1 );
  meshData.E2T(2,J(rind)) = T(rind);  
  
  % Generate ELInd  
  meshData.ELInd = zeros(2, meshData.nE);
  t2e = reshape(meshData.T2E', 1, maxTn*meshData.nT);
  ind = ( t2e~=0 );
  rowind = (1-sign(t2e))/2+1;
  colind = abs(t2e);
  values = reshape(repmat((1:maxTn)', 1, meshData.nT)', 1, maxTn*meshData.nT);
  meshData.ELInd = meshData.ELInd + sparse(rowind(ind), colind(ind), ...
      values(ind), 2, meshData.nE);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Part 2: Creat tables E2BE and BE2E
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Find all boundary edges, which are edges with left or right triangle = 0.
  ind = union(find(meshData.E2T(1,:)==0), find(meshData.E2T(2,:)==0));
  
  % Reserve spaces for E2BE and BE2E
  meshData.E2BE = zeros(1, meshData.nE);
  meshData.BE2E = zeros(1, meshData.nBE);
  
  % Set the tables
  [temp, IE] = sortrows(meshData.E(:,ind)');
  [temp, IBE] = sortrows(meshData.BE');
  [temp, reverseIE] = sort(IE);
  meshData.E2BE(ind(IE)) = IBE;
  meshData.BE2E(IBE) = ind(reverseIE);
  
