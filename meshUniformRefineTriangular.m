function [meshData] = meshUniformRefineTriangular(meshData)
% Refine a triangular mesh uniformly.
%
% Remark: After unifirm refine, edges may not start from points with a
% lower index. However, this program guarantees that the edges and boundary
% edges have the same direction. The reason that we do not want to make
% all edge direction from smaller point indices to larger is that, this
% breaks the coarse-fine mesh relationship which is important in multigrid
% methods.

  if ~strcmp(meshData.elementType,'triangular')
    error('meshUniformRefineTriangular only works for triangular meshes!');
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Refine
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  
  % Step 0: Set some quantities
  % ---------------------------
  np = meshData.nP;
  ne = meshData.nE;
  nt = meshData.nT;
  nbe = meshData.nBE;
  ne2 = 2*ne;
  nt3 = nt*3;
  e1c = np+abs(meshData.T2E(1,:));
  e2c = np+abs(meshData.T2E(2,:));
  e3c = np+abs(meshData.T2E(3,:));
  
  % Step 1: Add new vertices
  % ---------------------------
  meshData.P(:, (np+1):(np+ne)) = ...
      ( meshData.P(:,meshData.E(1,:)) + meshData.P(:,meshData.E(2,:)) ) *0.5;
  
  % Step 2: Add new edges
  % ---------------------------
  meshData.E(:, (ne+1):(ne2+nt3)) = 0;
  % set two sub-edges of all original edges.
  % The edge order is: 
  %    first,  ne edges with vertices [startP, centerP]
  %    second, ne edges with vertices [endP,   centerP]
  meshData.E(:, (ne+1):(ne2)) = [meshData.E(2,1:ne); meshData.nP+(1:ne)];
  meshData.E(2, 1:ne) = np+(1:ne);
  % Set three new edges inside each original triangle.
  % Pay attention to the order and orientation.
  meshData.E(:, (ne2+1):3:end) = [e1c; e3c]; 
  meshData.E(:, (ne2+2):3:end) = [e2c; e1c]; 
  meshData.E(:, (ne2+3):3:end) = [e3c; e2c]; 
     
  % Step 3: Add new triangles
  % ---------------------------
  meshData.T(:, (nt+1):(4*nt)) = 0;
  % Add three sub-triangles who have one original vertex.
  % Pay attention to the orientation of these triangles.
  meshData.T(:, (nt+1):3:end) = ...
      [meshData.T(1,1:nt); e1c; e3c];
  meshData.T(:, (nt+2):3:end) = ...
      [meshData.T(2,1:nt); e2c; e1c];
  meshData.T(:, (nt+3):3:end) = ...
      [meshData.T(3,1:nt); e3c; e2c];
  % The new sub-triangle at the center inherits 
  % the original triangle's index.
  meshData.T(:, 1:nt) = [e1c; e2c; e3c]; %np+abs(meshData.T2E);   
  % Set subdomains
  meshData.TSubdomN(1,(nt+1):(4*nt)) = 0;
  meshData.TSubdomN((nt+1):3:end) = meshData.TSubdomN(1:nt);
  meshData.TSubdomN((nt+2):3:end) = meshData.TSubdomN(1:nt);
  meshData.TSubdomN((nt+3):3:end) = meshData.TSubdomN(1:nt);
  
  % Step 4: Add new boundary edges
  % ---------------------------
  meshData.BE(:, (nbe+1):(2*nbe)) = ...
      [meshData.BE(2,1:nbe); np+meshData.BE2E];
  meshData.BE(2, 1:nbe) = np+meshData.BE2E(:);
  meshData.BESegN((nbe+1):(2*nbe)) = meshData.BESegN(1:nbe);
  meshData.BEOrient((nbe+1):(2*nbe)) = -meshData.BEOrient(1:nbe);
  
  % Step 5: Set T2E
  % --------------------------- 
  % Each column of temp will store all six sub-edges
  % on the boundary of a triangle, in counterclockwise direction,
  % starting from the one [vertex1, centerOfOriginalEdge1].
  % Each sub-edge has the orientation that points to the center
  % of the original edges.
  temp = zeros(6, nt);
  temp([1,3,5],:) = abs(meshData.T2E);
  temp([2,4,6],:) = meshData.nE+abs(meshData.T2E);
  ind = ( meshData.T2E(1,:)<0 );
  temp([1,2], ind) = temp([2,1], ind);
  ind = ( meshData.T2E(2,:)<0 );
  temp([3,4], ind) = temp([4,3], ind);
  ind = ( meshData.T2E(3,:)<0 );
  temp([5,6], ind) = temp([6,5], ind);
  meshData.T2E(:, (nt+1):(4*nt)) = 0;
  meshData.T2E(:, (nt+1):3:end) = [temp(1,:); ne2+(1:3:nt3); -temp(6,:)];
  meshData.T2E(:, (nt+2):3:end) = [temp(3,:); ne2+(2:3:nt3); -temp(2,:)]; 
  meshData.T2E(:, (nt+3):3:end) = [temp(5,:); ne2+(3:3:nt3); -temp(4,:)];
  meshData.T2E(:, 1:nt) = -(ne2 + [2:3:nt3; 3:3:nt3; 1:3:nt3]);

  % Step 6: Set E2T and ELInd
  % ---------------------------
  meshData.E2T(:, 1:(ne2+nt3)) = 0;
  meshData.ELInd(:, 1:(ne2+nt3)) = 0;
  % For sub-edges of original edges.
  % We will use the fact that all subedges are pointed in to the center
  % of the original edge.
  meshData.E2T(1,meshData.T2E(1,(nt+1):end)) = (nt+1):(4*nt);
  meshData.E2T(2,-meshData.T2E(3,(nt+1):end)) = (nt+1):(4*nt);
  meshData.ELInd(1,meshData.T2E(1,(nt+1):end)) = 1;
  meshData.ELInd(2,-meshData.T2E(3,(nt+1):end)) = 3;
  % For three new internal edges.   
  meshData.E2T(:, (ne2+1):end) = [(nt+1):(4*nt); reshape([1:nt;1:nt;1:nt],1,nt3)];
  meshData.ELInd(1,(ne2+1):end) = 2;
  meshData.ELInd(2,(ne2+1):3:end) = 3;
  meshData.ELInd(2,(ne2+2):3:end) = 1;
  meshData.ELInd(2,(ne2+3):3:end) = 2;
  
  % Step 7: Set E2BE and BE2E
  % ---------------------------
  indE = find(meshData.E2BE>0);
  meshData.E2BE((ne+1):(ne2+nt3)) = 0;
  meshData.E2BE(ne+indE) = nbe + meshData.E2BE(indE);
  meshData.BE2E((nbe+1):(2*nbe)) = ne + meshData.BE2E(1:nbe);
  
  % Step 8: Set numbers
  % ---------------------------
  meshData.nP = meshData.nP+meshData.nE;
  meshData.nE = 2*meshData.nE+3*meshData.nT;
  meshData.nT = 4*meshData.nT;
  meshData.nBE = 2*meshData.nBE;

  
  