function [n1, n2, n3] = trgVecNormal(meshData)
% Only works when ( meshData.elementType == 'triangular' )
% Compute the unit outward normal vector of each triangle in the mesh.
% n1, n2, n3 are 2-by-meshData.nT matrices.
  
  if ~strcmp(meshData.elementType,'triangular')
      error('trgVecNormal only works when ( meshData.elementType == "triangular" )!');
  end
  
  [~,n] = edgeDirection(meshData.P, meshData.E);
  t2e = abs(meshData.T2E);
  n1 = zeros(2,meshData.nT);
  n2 = zeros(2,meshData.nT);
  n3 = zeros(2,meshData.nT);
  
  posind = ( meshData.T2E(1,:)>0 );
  negind = ( meshData.T2E(1,:)<0 );
  n1(:, posind) = n(:, t2e(1,posind));
  n1(:, negind) = -n(:, t2e(1,negind));
  
  posind = ( meshData.T2E(2,:)>0 );
  negind = ( meshData.T2E(2,:)<0 );
  n2(:, posind) = n(:, t2e(2,posind));
  n2(:, negind) = -n(:, t2e(2,negind));
  
  posind = ( meshData.T2E(3,:)>0 );
  negind = ( meshData.T2E(3,:)<0 );
  n3(:, posind) = n(:, t2e(3,posind));
  n3(:, negind) = -n(:, t2e(3,negind));