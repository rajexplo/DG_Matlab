function [csc1, csc2, csc3] = trgCscTheta(meshData)
  % Only works when ( meshData.elementType == 'triangular' )
  % Compute csc of internal angles \theta_i for each triangle in the mesh.
  % Each \theta_i, i=1,2,3, is the internal angle at vertex x_i.
  % csc1, csc2, csc3 are row vectors of dimension meshData.nT
  
  if ~strcmp(meshData.elementType,'triangular')
      error('trgCscTheta only works when ( meshData.elementType == "triangular" )!');
  end
  
  area = trgArea(meshData.P, meshData.T);
  edgeL = edgeLength(meshData.P, meshData.E);
  t2e = abs(meshData.T2E);
  
  csc1 = 0.5*edgeL(t2e(1,:)).*edgeL(t2e(3,:))./area;
  csc2 = 0.5*edgeL(t2e(1,:)).*edgeL(t2e(2,:))./area;
  csc3 = 0.5*edgeL(t2e(2,:)).*edgeL(t2e(3,:))./area;
  