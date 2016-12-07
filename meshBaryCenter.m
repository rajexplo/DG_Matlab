function [baryCenter] = meshBaryCenter(meshData)
% Find the bary center of element.
% Does not work for elementType=='trig-cluster'

switch meshData.elementType
    case 'triangular'
        baryCenter = (meshData.P(:,meshData.T(1,:)) + meshData.P(:,meshData.T(2,:)) ...
                     + meshData.P(:,meshData.T(3,:)) )*(1/3);
    case 'quadrilateral'
        baryCenter = (meshData.P(:,meshData.T(1,:)) + meshData.P(:,meshData.T(2,:)) ...
                     +meshData.P(:,meshData.T(3,:)) + meshData.P(:,meshData.T(4,:)))*(0.25);
    case 'trig-cluster'
        error('meshBaryCenter does not work for trig-cluster meshes!');
end