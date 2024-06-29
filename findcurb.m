function [curb] = findcurb(Railing_curb,height_curb,z_curb,maxDistance2)
%find the curb in ptcloud
[X1,Y1,Z1] = XYZ_ptC(Railing_curb);
X1min = min(X1);
X1max = max(X1);
Y1min = min(Y1);
Y1max = max(Y1);
Z1min = min(Z1);
Z1max = max(Z1);

roi = [X1min+0.1 X1max-0.1 Y1min Y1max Z1min Z1min + height_curb + z_curb];%delete two sides noise
indices = findPointsInROI(Railing_curb,roi);
curb_cut = select(Railing_curb,indices);
%fit curb plane
referenceVector = [0,0,1];
maxAngularDistance = 5;
[model1,inlierIndices,outlierIndices] = pcfitplane(curb_cut,...
            maxDistance2,referenceVector,maxAngularDistance);
curb = select(curb_cut,inlierIndices);
end