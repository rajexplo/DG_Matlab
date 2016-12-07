function meshPlotWithIndices(meshData, varargin)
  % Plot the mesh with indices of points, triangles, edges, etc.
  % varargin contains
  %  1. a string containing one or more of 
  %      p:  draw point indices
  %      t:  draw element indices
  %      e:  draw edge indices together with direction
  %      b:  draw boundary edge indices together with direction
  %
  %  2. font size
  %
  %  By default, it plot 'pt' using default font size 10.
  %
  %  Remark:
  %  (1) If t is chosen, it draws the element indices in red, with a green
  %  dashed line connecting the index with the starting point of this
  %  element. 
  %  (2) Boundary edge indices are enclosed in a rectangular box, in order
  %  to distinguish them from internal edges. If both e and b are chosen,
  %  the small rectangular box encloses two indices, the first one is edge
  %  index and the second one is BE index.
  %
  %  Example: 
  %    meshPlotWithIndices(meshData);
  %    meshPlotWithIndices(meshData, 'pe');
  %    meshPlotWithIndices(meshData, 'pe', 14);  
  
  if strcmp(meshData.elementType, 'trig-cluster')
      error('meshPlotWithIndices currently does not work for trig-cluster meshes');
  end
  
  defaultplot = 'pt';
  defaultfontsize = 10;
  if nargin > 1
    defaultplot = varargin{1};
  end
  if nargin > 2
    defaultfontsize = varargin{2};
  end
  
  clf; 
  hold on
  
  % Draw edges
  line([meshData.P(1,meshData.E(1,:)); meshData.P(1,meshData.E(2,:))], ...
      [meshData.P(2,meshData.E(1,:)); meshData.P(2,meshData.E(2,:))], ...
      'Color', 'k');

  % Draw arrows that indicate edge directions
  if ismember('e', defaultplot)
      [ax, ay] = edgePointCoord(meshData.P, meshData.E, 0);
      [ll, tt, ~] = edgeLengthDirection(meshData.P, meshData.E);
      ll = ll*0.75;     
      quiver(ax, ay, ll.*tt(1,:), ll.*tt(2,:),0,'k');
  end
  if ismember('b', defaultplot)
      [ax, ay] = edgePointCoord(meshData.P, meshData.BE, 0);
      [ll, tt, ~] = edgeLengthDirection(meshData.P, meshData.BE);
      ll = ll*0.75;
      quiver(ax, ay, ll.*tt(1,:), ll.*tt(2,:),0,'k');
  end

  % Draw indices
  if ismember('p', defaultplot)
    text(meshData.P(1,:), meshData.P(2,:), num2str((1:meshData.nP)'), ...
	'Color','blue','FontWeight','bold','FontSize',defaultfontsize);
  end
  if ismember('t', defaultplot)
    [cx, cy] = trgPointCoord(meshData.P, meshData.T(1:3,:), [1/3, 1/3]);
    text(cx, cy, num2str((1:meshData.nT)'), ...
	'Color','red','EdgeColor','red','FontWeight','bold','FontSize',defaultfontsize);
    line([cx; meshData.P(1, meshData.T(1,:))], [cy; meshData.P(2, meshData.T(1,:))], ...
	'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);
  end
  if ismember('e', defaultplot)&&(~ismember('b', defaultplot))
    ce = 0.5*(meshData.P(:, meshData.E(1,:)) + meshData.P(:, meshData.E(2,:)));
    text(ce(1,:), ce(2,:), num2str((1:meshData.nE)'), ...
	'Color','magenta','FontWeight','bold','FontSize',defaultfontsize);
  end
  if ismember('b', defaultplot)&&(~ismember('e', defaultplot))
    cbe = 0.5*(meshData.P(:, meshData.BE(1,:)) + meshData.P(:, meshData.BE(2,:)));
    text(cbe(1,:), cbe(2,:), num2str((1:meshData.nBE)'), ...
	'Color','magenta','EdgeColor','magenta','FontWeight','bold','FontSize',defaultfontsize);
  end
  if ismember('e', defaultplot)&&ismember('b', defaultplot)    
    ce = 0.5*(meshData.P(:, meshData.E(1,:)) + meshData.P(:, meshData.E(2,:)));
    ieInd = find(meshData.E2BE==0);
    estring = num2str((1:meshData.nE)');
    text(ce(1,ieInd), ce(2,ieInd), estring(ieInd,:), ...
	'Color','magenta','FontWeight','bold','FontSize',defaultfontsize);    
    bestring = [estring(meshData.BE2E, :), repmat(', ',meshData.nBE, 1), num2str((1:meshData.nBE)')];
    text(ce(1,meshData.BE2E), ce(2,meshData.BE2E), bestring, ...
	'Color','magenta','EdgeColor','magenta','FontWeight','bold','FontSize',defaultfontsize);
  end
  
  axis equal;
  axis off
  hold off