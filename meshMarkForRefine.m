function [mark] = meshMarkForRefine(meshData, eta, strategy)
%
% Mark triangles for adaptive refinement.
% Only works for triangular meshes.
% eta is a given vector of dim = nT, which stores the a posteriori error estimator.
%

  if ~strcmp(meshData.elementType,'triangular')
    error('meshMarkForRefine only works for triangular meshes!');
  end

  mark = zeros(1,meshData.nT);

  switch strategy
    case 'maximum'
      maxeta = max(eta);
      mark(eta>maxeta/2) = 1;
    case 'bulk'
      total = norm(eta,2);
      [sortedeta, ind] = sort(eta,2,'descend');
      s = sqrt(cumsum(sortedeta.^2));
      lastone = max(union(find(s<total*0.75), 1));
      mark(ind(1:lastone)) = 1;
    case 'local'
      theta = 1.5;
      % generate P2T table
      P2T = zeros(16, meshData.nP);
      P2TInd = ones(1, meshData.nP);
      for i=1:meshData.nT
	    pInd = meshData.T(1, i);
	    P2T(P2TInd(pInd), pInd) = i;
	    P2TInd(pInd) = P2TInd(pInd) + 1;
	    pInd = meshData.T(2, i);
	    P2T(P2TInd(pInd), pInd) = i;
	    P2TInd(pInd) = P2TInd(pInd) + 1;
	    pInd = meshData.T(3, i);
	    P2T(P2TInd(pInd), pInd) = i;
	    P2TInd(pInd) = P2TInd(pInd) + 1;
      end
      T2T = zeros(24, meshData.nT);
      T2TInd = ones(1, meshData.nT);
      for i=1:meshData.nT
	    temp = union(P2T(:,meshData.T(1,i)), union(P2T(:,meshData.T(2,i)), P2T(:,meshData.T(3,i))));
	    nonzeroind = find(temp~=0);
	    T2TInd(i) = length(nonzeroind);
	    T2T(1:T2TInd(i),i) =  temp(nonzeroind);
	    if (eta(i)>theta*mean(eta(temp(nonzeroind))))
	      mark(i) = 1;
	    end
      end      
    otherwise 
      maxeta = max(eta);
      mark(eta>maxeta/2) = 1;
  end