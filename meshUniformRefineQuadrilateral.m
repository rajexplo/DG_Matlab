function [meshData] = meshUniformRefineQuadrilateral(meshData)
% Refine a quadrilateral mesh uniformly.
%
% Remark: After unifirm refine, edges may not start from points with a
% lower index. However, this program guarantees that the edges and boundary
% edges have the same direction. The reason that we do not want to make
% all edge direction from smaller point indices to larger is that, this
% breaks the coarse-fine mesh relationship which is important in multigrid
% methods.

  if ~strcmp(meshData.elementType,'quadrilateral')
    error('meshUniformRefineQuadrilateral only works for quadrilateral meshes!');
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
  nt4 = nt*4;
  e1c = np+abs(meshData.T2E(1,:));
  e2c = np+abs(meshData.T2E(2,:));
  e3c = np+abs(meshData.T2E(3,:));
  e4c = np+abs(meshData.T2E(4,:));
  qc = np+ne+(1:nt);
  
  % Step 1: Add new vertices
  % ---------------------------  
  meshData.P(:, (np+1):(np+ne+nt)) = ...
      [( meshData.P(:,meshData.E(1,:)) + meshData.P(:,meshData.E(2,:)) ) *0.5, ...
       ( meshData.P(:,meshData.T(1,:)) + meshData.P(:,meshData.T(2,:)) ...
        +meshData.P(:,meshData.T(3,:)) + meshData.P(:,meshData.T(4,:)) ) *0.25];
   
  % Step 2: Add new edges
  % ---------------------------
  meshData.E(:, (ne+1):(ne2+nt4)) = 0;
  % set two sub-edges of all original edges.
  % The edge order is: 
  %    first,  ne edges with vertices [startP, centerP]
  %    second, ne edges with vertices [endP,   centerP]
  meshData.E(:, (ne+1):(ne2)) = [meshData.E(2,1:ne); meshData.nP+(1:ne)];
  meshData.E(2, 1:ne) = np+(1:ne);
  % Set four new edges inside each original triangle.
  % The order is from points at edge center to point at the barycenter.
  meshData.E(:, (ne2+1):4:end) = [e1c; qc];
  meshData.E(:, (ne2+2):4:end) = [e2c; qc];
  meshData.E(:, (ne2+3):4:end) = [e3c; qc];
  meshData.E(:, (ne2+4):4:end) = [e4c; qc];
  
  % Step 3: Add new quadrilaterals
  % ---------------------------
  t = meshData.T;
  meshData.T(:, (nt+1):(4*nt)) = 0;
  % The ith sub-quadrilateral inherits the ith vertex of the original quad.
  meshData.T(:, 1:4:end) = [t(1,:); e1c; qc; e4c];
  meshData.T(:, 2:4:end) = [t(2,:); e2c; qc; e1c];
  meshData.T(:, 3:4:end) = [t(3,:); e3c; qc; e2c];
  meshData.T(:, 4:4:end) = [t(4,:); e4c; qc; e3c];
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
  % Each column of temp will store all eight sub-edges
  % on the boundary of a quadrilateral, in counterclockwise direction,
  % starting from the one [vertex1, centerOfOriginalEdge1].
  % Each sub-edge has the orientation that points to the center
  % of the original edges.
  temp = zeros(8, nt);
  temp([1,3,5,7],:) = abs(meshData.T2E);
  temp([2,4,6,8],:) = meshData.nE+abs(meshData.T2E);
  ind = ( meshData.T2E(1,:)<0 );
  temp([1,2], ind) = temp([2,1], ind);
  ind = ( meshData.T2E(2,:)<0 );
  temp([3,4], ind) = temp([4,3], ind);
  ind = ( meshData.T2E(3,:)<0 );
  temp([5,6], ind) = temp([6,5], ind);
  ind = ( meshData.T2E(4,:)<0 );
  temp([7,8], ind) = temp([8,7], ind);
  meshData.T2E(:, (nt+1):(4*nt)) = 0;
  iedge1 = ne2+(1:4:nt4);
  iedge2 = ne2+(2:4:nt4);
  iedge3 = ne2+(3:4:nt4);
  iedge4 = ne2+(4:4:nt4);
  meshData.T2E(:, 1:4:end) = [temp(1,:); iedge1; -iedge4; -temp(8,:)];
  meshData.T2E(:, 2:4:end) = [temp(3,:); iedge2; -iedge1; -temp(2,:)];
  meshData.T2E(:, 3:4:end) = [temp(5,:); iedge3; -iedge2; -temp(4,:)];
  meshData.T2E(:, 4:4:end) = [temp(7,:); iedge4; -iedge3; -temp(6,:)];
  
  % Step 6: Set E2T and ELInd
  % ---------------------------
  meshData.E2T(:, 1:(ne2+nt4)) = 0;
  meshData.ELInd(:, 1:(ne2+nt4)) = 0;
  % For sub-edges of original edges.
  % We will use the fact that all subedges are pointed in to the center
  % of the original edge.
  meshData.E2T(1,meshData.T2E(1,1:end)) = 1:nt4;
  meshData.E2T(2,-meshData.T2E(4,1:end)) = 1:nt4;
  meshData.ELInd(1,meshData.T2E(1,1:end)) = 1;
  meshData.ELInd(2,-meshData.T2E(4,1:end)) = 4;
  % For four new internal edges.   
  q1 = 1:4:nt4;
  q2 = 2:4:nt4;
  q3 = 3:4:nt4;
  q4 = 4:4:nt4;
  meshData.E2T(:, (ne2+1):4:end) = [q1; q2];
  meshData.E2T(:, (ne2+2):4:end) = [q2; q3];
  meshData.E2T(:, (ne2+3):4:end) = [q3; q4];
  meshData.E2T(:, (ne2+4):4:end) = [q4; q1];
  meshData.ELInd(1, (ne2+1):end) = 2;
  meshData.ELInd(2, (ne2+1):end) = 3;
  
  % Step 7: Set E2BE and BE2E
  % ---------------------------
  indE = find(meshData.E2BE>0);
  meshData.E2BE((ne+1):(ne2+nt4)) = 0;
  meshData.E2BE(ne+indE) = nbe + meshData.E2BE(indE);
  meshData.BE2E((nbe+1):(2*nbe)) = ne + meshData.BE2E(1:nbe);
  
  % Step 8: Set numbers
  % ---------------------------
  meshData.nP = meshData.nP+meshData.nE+meshData.nT;
  meshData.nE = 2*meshData.nE+4*meshData.nT;
  meshData.nT = 4*meshData.nT;
  meshData.nBE = 2*meshData.nBE;
  
  
  