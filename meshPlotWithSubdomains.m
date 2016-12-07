function meshPlotWithSubdomains(meshData)
% Draw the mesh where subdomains are indicated by different colors.

  clf;
  
  % Use colors to indicate subdomains.
  switch meshData.elementType
      case 'triangular'
          xx = [meshData.P(1,meshData.T(1,:)); meshData.P(1,meshData.T(2,:)); meshData.P(1,meshData.T(3,:))];
          yy = [meshData.P(2,meshData.T(1,:)); meshData.P(2,meshData.T(2,:)); meshData.P(2,meshData.T(3,:))];  
          p = repmat(meshData.TSubdomN,3, 1);
          H1=patch(xx,yy,p); 
          set(H1,'EdgeColor',[0,0,0]); 
      case 'quadrilateral'
          xx = [meshData.P(1,meshData.T(1,:)); meshData.P(1,meshData.T(2,:)); ...
              meshData.P(1,meshData.T(3,:)); meshData.P(1,meshData.T(4,:))];
          yy = [meshData.P(2,meshData.T(1,:)); meshData.P(2,meshData.T(2,:)); ...
              meshData.P(2,meshData.T(3,:)); meshData.P(2,meshData.T(4,:))];  
          p = repmat(meshData.TSubdomN,4, 1);
          H1=patch(xx,yy,p); 
          set(H1,'EdgeColor',[0,0,0]); 
      case {'trigcluster'}
          error('meshPlotWithSubdomains currently does not work for trig-cluster meshes');
  end
  
  view(2);
  axis equal
  axis off