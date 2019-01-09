% ----------------------------------------------------------------------
%  MaxPooling1D behaviour model
%
%   Document: section 4.2.4
%   Based on keras definition: https://keras.io/layers/pooling/
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = MaxPooling1D(pp,gp,input_shape)
% Inputs:
% (1) pp                output shape of the layer given an input shape and parameters
% (2) gp                complexity of the layer given an input shape and parameters
% (3) input_shape       number of parameters of the layer given an input shape and parameters
% Outputs:
% (1) output_shape      output shape of the layer given an input shape and parameters
% (2) complexity        complexity of the layer given an input shape and parameters
% (3) nr_parameters     number of parameters of the layer given an input shape and parameters
%
% Usage example (chain):
%   - class_name: MaxPooling2D
%     config:
%       pool_size: dim1
%       strides: dim1
%       padding: valid (no padding) or something else (padding)
%
%   We don't work with the 'channels_first' or 'channels_last' convention
%   like in Keras. In the general configuration file one can set up the
%   index ids for the channels, feature and time indices. By default these
%   are 1, 2 and 3 respectively (like 'channels_first' in keras). All
%   layers follow this convention.

function [output_shape, complexity, nr_parameters] = MaxPooling1D(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    nr_parameters = zeros(1,1);
    % If certain params are not specified, fill them up
    if ~isfield(pp,'padding'), pp.padding = 'lol'; end;
    % output shape
    output_shape(1,[gp.chid gp.featid, gp.frameid]) = [input_shape(gp.chid) 1 (input_shape(gp.frameid)-pp.pool_size)./pp.strides+1]; %get output shape
    if strcmp(pp.padding,'valid'), output_shape = ceil(output_shape); else, output_shape = floor(output_shape); end;
    if sum(output_shape<1), error('Input shape is not big enough to support atleast one pool operation.'); end;
    % complexity
    pool_comp = prod(pp.pool_size)*input_shape(gp.chid)-1; %Comps for one filter operations
    pool_its = prod(output_shape([gp.featid gp.frameid])); %amount of filter conv iterations
    complexity(1,gp.compid) = pool_comp*pool_its; %update comparisons (max/min) 
    % number of parameters
    % /
end