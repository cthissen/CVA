function [vorts,bulkVort]=sample_scale_CVA_4_0(g,ebsd)
% written by Zachary D. Michels; February, 2015

%% References
% Zachary D. Michels, Seth C. Kruckenberg, Joshua R. Davis, and Basil Tikoff
% Determining vorticity axes from grain-scale dispersion of
% crystallographic orientations Geology, G36868.1, first published on July
% 17, 2015, doi:10.1130/G36868.1


%% NOTES TO USERS and REFERENCE INFORMATION

% !*** IMPORTANT ***! This function requires MTEX v4.0 Some alteration may
% be required for use with subsequent versions of MTEX. However, MOST of
% the calculations do not require MTEX specific functions (mainly MTEX is
% used for passing intragranular orientation solutions to the custom
% scripts), and the code should be easily adapted. For consultation
% regarding this analysis, please contact Z. Michels through GitHub
% repository:(https://github.com/zmichels/CVA.git)

% NOTE: All grain objects passed to this function must contain more than 1
% indexed orientation solution... a good rule of thumb is >3 solutions. The
% comments immediately below give an example of how this might be
% accomplished using MTEX 4.0 to make a new set of grains, 'g', which
% satisfy these conditions:

% ** EXAMPLE **
% [grains,ebsd.grainId] =
% calcGrains(ebsd,'angle',10*degree,'keepNotIndexed');
%
% condition = grains.grainSize >= 3 & grains.phase>0;
%
% g=grains(condition);


% ************************************************************************
%% References
% Zachary D. Michels, Seth C. Kruckenberg, Joshua R. Davis, and Basil Tikoff
% Determining vorticity axes from grain-scale dispersion of
% crystallographic orientations Geology, G36868.1, first published on July
% 17, 2015, doi:10.1130/G36868.1

% ************************************************************************


%% Setup: initialize variables for sake of loops

% number of grains:
numg=size(g,1)

% for keeping track of progress in for loop:
div=round(numg/10);
count=div;

% initialize variables (MTEX vector3d object for vorticity vectors)
vorts=vector3d();

%% Analysis Loop:
% This loop passes data from one grain at a time to the intragranular
% (single grain) dispersion script. The intragranular dispersion function
% applies a principal geodesic analysis and returns a best-fit axis that
% describes rotational crystallographic distortion within each grain. A
% vector for each grain-scale vorticity axis is stored in the variable
% 'vorts'.


for i = 1:numg
    % Pass one grain object from the GrainSet to the function for
    % intragranular (single-grain) dispersion analysis using Principal
    % Geodesic Analysis
    
    [vorts(i)]=intragranular_CVA_4_0(ebsd(g(i)));
    
    
    % Keep track of for loop progress and print to consoloe screen:
    perc=round(i/numg*100);
        if i==count            
            fprintf('\n\n%i percent done...\n\n',perc)
            count=count+div;
        end
end


%% Remove nonsensical vectors (i.e., [0,0,0]) 
% for sake of kernel density estimation (below):

[x,y,z]=double(vorts);
IzeroX = find(~x)';
IzeroY = find(~y)';
IzeroZ = find(~z)';
intXYZ=intersect(intersect(IzeroX,IzeroY,'rows'),IzeroZ);
vorts(intXYZ)=[];


%% Try Kernel Density Estimation to get a best fit "bulk" vorticity vector.
% Define a kernel density estimation with specified halfwidth. MTEX default
% uses the de la Vallee Poussin kernel:
r = plotS2Grid('resolution',0.25*degree,'antipodal');
kde = kernelDensityEstimation(vorts,r,'antipodal','halfwidth',10*degree);
[~,I]=max(kde);

% get vector and negated vector (antipodal) of best-fit axis:
bulkVort=[r(I),-r(I)];



