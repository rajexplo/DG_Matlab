function meshDisp(meshData)
% display meshData structure

  fprintf(' elementType == %s\n', meshData.elementType);
  
  fprintf(' Points: %d\n', meshData.nP);
  disp(meshData.P)
  
  fprintf(' Elements: %d\n', meshData.nT);
  disp(meshData.T)
  
  fprintf(' Subdomains: %d\n',meshData.nSubdom);
  disp(meshData.TSubdomN);
   
  fprintf(' Edges: %d\n', meshData.nE);
  disp(meshData.E)
  
  fprintf(' Boundary edges: %d\n', meshData.nBE);
  disp(meshData.BE)
  fprintf(' BE Segment number: \n');
  disp(meshData.BESegN);
  fprintf(' BE Orientation: \n');
  disp(meshData.BEOrient);
  
  fprintf(' T2E table: \n');
  disp(meshData.T2E);
  
  fprintf(' E2T table: \n');
  disp(meshData.E2T);
  
  fprintf(' ELInd table: \n');
  disp(meshData.ELInd);
  
  fprintf(' E2BE table: \n');
  disp(meshData.E2BE);
  
  fprintf(' BE2E table: \n');
  disp(meshData.BE2E);
  
  if strcmp(meshData.elementType, 'trig-cluster')
      fprintf(' This is a trig-cluster mesh.\n');
      
      fprintf(' Clusters: %d\n', meshData.nC);
      disp(meshData.C)
      
      fprintf(' T2C table:\n');
      disp(meshData.T2C);
      
      fprintf(' Interfaces: %d\n',meshData.nInterface);
      disp(meshData.Interface);
  end
  
  