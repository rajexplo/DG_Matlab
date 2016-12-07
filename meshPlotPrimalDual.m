function meshPlotPrimalDual(meshData, dualMesh)
% Draw the primal and the dual mesh together
clf;
hold on
% dual Mesh
ii = dualMesh.E(:,dualMesh.Interface);
line([dualMesh.P(1,ii(1,:)); dualMesh.P(1,ii(2,:))], ...
      [dualMesh.P(2,ii(1,:)); dualMesh.P(2,ii(2,:))], ...
      'Color', 'r');
% primal mesh
line([meshData.P(1,meshData.E(1,:)); meshData.P(1,meshData.E(2,:))], ...
      [meshData.P(2,meshData.E(1,:)); meshData.P(2,meshData.E(2,:))], ...
      'Color', 'k');
hold off
axis off, axis equal;