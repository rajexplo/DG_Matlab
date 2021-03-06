function [meshData] = meshAdaptiveRefine(meshData, triangle_mark)  
% Refine the mesh using the newest vertex bisection method.
% In each triangle, the "newest vertex is called the "peak"
% and the edge oppsite to this vertex is called the "base".
% 
% Inputs:
%   mesh - mesh struct, see meshInfo.m for details.
%          In mesh.T, the first vertex will be the peak and
%          hence the second edge will be the base.
%     (Remark: call meshMakeLongestEdgeSuitable to make triangular meshes
%     ready for the adaptive refinement.)
%
%   triangle_mark - an nT-dim vector containing 0 and positive integers
%                   triangle_mark(i) > 0 means the ith triangle 
%                   will be refined. 
%  
%  Remark: we choose not to use recursive function call in the
%  implementation of the adaptive mesh refine, in order to inprove the
%  performance. Notice that our function knows the total number of new
%  vertices, triangles, edges to be added. Then it allocates the memory in
%  bulk size. This should be faster, especially in Matlab, than increase the
%  size of matrices/vectors one column by one column.

  if ~strcmp(meshData.elementType,'triangular')
    error('meshAdaptiveRefine only works for triangular meshes!');
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Part 1: Mark triangles and edges to be refined.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Initially, marked edges contain bases of all marked triangles.
  edge_mark = zeros(1, meshData.nE);
  edge_mark(abs(meshData.T2E(2, triangle_mark==1))) = 1; 
  
  % To ensure geometric conformity of the mesh, we check repeatedly
  % and mark new triangles or edges if needed, until there's nothing
  % more to mark. 
  %   n -- number of new marks in current sweep. n = 0 means
  %        the current marked set will give a conforming meshData.  
  n = 1;
  while n
    [n, triangle_mark, edge_mark] = markEdge(meshData, triangle_mark, edge_mark);
  end
  
  % Marked edges are indexed. Hence The new vertex at the center of the
  % marked edge will have a unique index = nPofOriginalMesh + markedEdgeIndex
  edge_mark(edge_mark>0) = 1:nnz(edge_mark);
  
  % markedT and markedE stores the indices of marked triangles and edges.
  markedT = find(triangle_mark>0);
  markedE = find(edge_mark>0);  
  
  % be_mark and markedBE are boundary edge marks.
  be_mark = edge_mark(meshData.BE2E);
  markedBE = find(be_mark>0);

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Part 2: Add new vertices, triangles and boundaryEdges to the meshData.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Add new vertices
  meshData.P(:,(meshData.nP+1):(meshData.nP+length(markedE))) = ... 
      ( meshData.P(:,meshData.E(1,markedE)) + meshData.P(:,meshData.E(2,markedE)) ) *0.5;

  % Set triangles
  % First, compute the total number of new triangles
  % Note that each marked internal edge brings 2 more triangles and each
  % marked boundary edge only brings 1 more.
  nTInc = 2*length(markedE) - length(markedBE);
  % Allocate memory
  meshData.T(:, (meshData.nT+1):(meshData.nT+nTInc)) = 0;
  meshData.TSubdomN(:, (meshData.nT+1):(meshData.nT+nTInc)) = 0;
  meshData.T2E(:, (meshData.nT+1):(meshData.nT+nTInc)) = 0;
  % bisect triangles
  for i=1:length(markedT) 
    % t2emark is the edge_mark of triangle i.
    t2emark = edge_mark(abs(meshData.T2E(:,markedT(i))));
    
    % Bisect triangle i.
    [meshData, leftTind, rightTind] = bisect(markedT(i), meshData, edge_mark);    
    
    % Bisect left triangle if needed.
    if t2emark(1)
      meshData = bisect(leftTind, meshData, edge_mark);
    end
    
    % Bisect right triangle if needed.
    if t2emark(3)      
      meshData = bisect(rightTind, meshData, edge_mark);
    end
  end
 
  % set boundary edges.
  % First, compute the total number of new boundary edges
  nBEInc = length(markedBE);
  % Allocarte memory
  meshData.BE(:, (meshData.nBE+1):(meshData.nBE+nBEInc)) = 0;
  meshData.BESegN(:, (meshData.nBE+1):(meshData.nBE+nBEInc)) = 0;
  meshData.BEOrient(:, (meshData.nBE+1):(meshData.nBE+nBEInc)) = 0;
  % bisect boundary edges
  for i=1:length(markedBE)
    % set BE start from the end of current BE and end at the center.
    meshData.BE(:,meshData.nBE+1) = meshData.BE([2,1],markedBE(i));
    meshData.BESegN(meshData.nBE+1) = meshData.BESegN(markedBE(i));
    meshData.BEOrient(meshData.nBE+1) = -meshData.BEOrient(markedBE(i));
    % set the ends of both sub-BE of the current BE to be the center.
    meshData.BE(2,[markedBE(i),meshData.nBE]) = meshData.nP + be_mark(markedBE(i));
    % increase nBE
    meshData.nBE = meshData.nBE+1;
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Final clean up: set the rest of the mesh data.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  meshData.nP = size(meshData.P, 2);
  meshData.nBE= size(meshData.BE, 2);
  meshData.nT = size(meshData.T, 2);
  meshData.nE = (3*meshData.nT-meshData.nBE)/2+meshData.nBE;
  meshData = meshConstructEdgeData(meshData);
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subroutines.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
function [n, triangle_mark, edge_mark] = markEdge(meshData, triangle_mark, edge_mark)   
% This function completes one sweep of marking triangles-and-edges.
% It does two things: 
%   (1) Bases of all marked triangles should be marked (edgesShouldBeMarked)
%       Record the number of edgesShouldBeMarked but not marked, and mark them.
%   (2) Triangles with one marked edge should be marked (trianglesShouldBeMarked)
%       Record the number of triangleShouldBeMarked but not marked, and mark
%       them.
%
% n -- The number of total marks (triangle and edge) done in this sweep.
%      n = 0 means no more mark needed and the mesh is ready to be bisected.

  edgesShouldBeMarked = abs(meshData.T2E(2, triangle_mark>0));
  temp_edge_mark = edge_mark(edgesShouldBeMarked);
  n = length(temp_edge_mark) - nnz(temp_edge_mark); 
  edge_mark(edgesShouldBeMarked) = 1;
  
  ind = (edge_mark>0);  
  trianglesShouldBeMarked = nonzeros(union(meshData.E2T(1,ind),meshData.E2T(2,ind)));
  temp_triangle_mark = triangle_mark(trianglesShouldBeMarked);
  n = n + length(temp_triangle_mark) - nnz(temp_triangle_mark);
  triangle_mark(trianglesShouldBeMarked) = 1;

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [meshData, leftTind, rightTind] = bisect(i, meshData, edge_mark)  
% Bisect triangle i.
% It returns the updated mesh and the indices of the left and right sub-triangles.

  % indP -- index of the new vertex at the center of the base.
  indP = meshData.nP + edge_mark(abs(meshData.T2E(2,i)));
  
  % Set vertices and subdomain info for the left and right sub-triangles, 
  % and make sure both of them have the new vertex as peaks.
  meshData.T(:,[i,meshData.nT+1]) = [indP, meshData.T(1,i), meshData.T(2,i); ...
    indP, meshData.T(3,i), meshData.T(1,i)]';
  meshData.TSubdomN([i, meshData.nT+1]) = [meshData.TSubdomN(i), meshData.TSubdomN(i)];

  % Set the base of two sub-triangles. This is important since the subtriangles
  % may need to be bisected later.
  meshData.T2E(2,[i,meshData.nT+1]) = [meshData.T2E(1,i), meshData.T2E(3,i)];
  
  % Indices of the left and right sub-triangles.
  leftTind = i;
  rightTind = size(meshData.T2E,2);
  
  % increase nT
  meshData.nT = meshData.nT+1;