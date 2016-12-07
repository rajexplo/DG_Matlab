function [t1, t2, t3] = trgVecTangent(meshData)
% Only works when ( meshData.elementType == 'triangular' )
% Compute the unit tangent vector of each triangle in the mesh,
% in the counter-clockwise direction (positive orientation).
% t1, t2, t3 are 2-by-meshData.nT matrices.

  if ~strcmp(meshData.elementType,'triangular')
      error('trgVecNormal only works when ( meshData.elementType == "triangular" )!');
  end

  [t,~] = edgeDirection(meshData.P, meshData.E);
  t2e = abs(meshData.T2E);
  t1 = zeros(2,meshData.nT);
  t2 = zeros(2,meshData.nT);
  t3 = zeros(2,meshData.nT);
  
  posind = ( meshData.T2E(1,:)>0 );
  negind = ( meshData.T2E(1,:)<0 );
  t1(:, posind) = t(:, t2e(1,posind));
  t1(:, negind) = -t(:, t2e(1,negind));
  
  posind = ( meshData.T2E(2,:)>0 );
  negind = ( meshData.T2E(2,:)<0 );
  t2(:, posind) = t(:, t2e(2,posind));
  t2(:, negind) = -t(:, t2e(2,negind));
  
  posind = ( meshData.T2E(3,:)>0 );
  negind = ( meshData.T2E(3,:)<0 );
  t3(:, posind) = t(:, t2e(3,posind));
  t3(:, negind) = -t(:, t2e(3,negind));