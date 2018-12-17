% ----------------------------------------------------------------------
%  MaxPooling2D behaviour model
%
%   Document: section 4.2.4
%   Based on keras definition: https://keras.io/layers/pooling/
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = MaxPooling2D(pp,gp,input_shape)
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
%       pool_size: [dim1, dim2]
%       strides: [dim1, dim2]
%       padding: valid (no padding) or something else (padding)
%
%   We don't work with the 'channels_first' or 'channels_last' convention
%   like in Keras. In the general configuration file one can set up the
%   index ids for the channels, feature and time indices. By default these
%   are 1, 2 and 3 respectively (like 'channels_first' in keras). All
%   layers follow this convention.

function [output_shape, complexity, nr_parameters] = MaxPooling2D(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    nr_parameters = zeros(1,1);
    % If certain params are not specified, fill them up
    if ~isfield(pp,'padding'), pp.padding = 'valid'; end;
    % output shape
    if strcmp(pp.padding,'valid'), P = [0 0]; else, P = pp.pool_size(2:3); end; % padding
    output_shape(1,[gp.chid gp.featid, gp.frameid]) = [input_shape(gp.chid) floor((input_shape([gp.featid, gp.frameid])-pp.pool_size+P)./pp.strides+1)]; %get output shape
    % complexity
    pool_comp = prod(pp.pool_size)*input_shape(gp.chid)-1; %Comps for one filter operations
    if strcmp(pp.padding,'valid'), P = [0 0]; else, P = pp.pool_size; end; % padding
    pool_its = prod(floor(floor((input_shape([gp.featid, gp.frameid])-pp.pool_size+P)./pp.strides+1))); %amount of filter conv iterations
    complexity(1,gp.compid) = pool_comp*pool_its; %update comparisons (max/min) 
    % number of parameters
    % /
end