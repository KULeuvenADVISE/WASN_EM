% ----------------------------------------------------------------------
%  Neural Network Conv2D behaviour model
%
%   Document: section 4.2.3
%   Based on keras definition: https://keras.io/layers/convolutional/
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = Conv2D(pp,gp,input_shape)
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
%   - class_name: Conv2D
%     config:
%       input_shape: [dim1,dim2,dim3] # e.g. [channel, data, time]
%       filters: 64 # amount of filters 
%       kernel_size: [dim1, dim2]
%       strides: [1,1]
%       padding: valid (no padding) or something else (padding)
%       use_bias: 1/0
%       activation: softmax % optionally you could add an activation to the chain. Not mandatory.
%
%   We don't work with the 'channels_first' or 'channels_last' convention
%   like in Keras. In the general configuration file one can set up the
%   index ids for the channels, feature and time indices. By default these
%   are 1, 2 and 3 respectively (like 'channels_first' in keras). All
%   layers follow the convention.

function [output_shape, complexity, nr_parameters] = Conv2D(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    %nr_parameters = zeros(1,1);
    % If certain params are not specified, fill them up
    if ~isfield(pp,'padding'), pp.padding = 'lol'; end;
    if ~isfield(pp,'data_format'), pp.data_format = 'channels_last'; end;
    % output shape
    output_shape(1,[gp.chid gp.featid gp.frameid]) = [pp.filters (input_shape([gp.featid, gp.frameid])-pp.kernel_size)./pp.strides+1]; %get output shape
    if strcmp(pp.padding,'valid'), output_shape = ceil(output_shape); else, output_shape = floor(output_shape); end;
    if sum(output_shape<1), error('Input shape is not big enough to support atleast one conv. operation.'); end;
    % complexity
    filter_mac = prod(pp.kernel_size+pp.use_bias)*input_shape(gp.chid); %MAC for one filter operation
    if strcmp(pp.padding,'valid'), P = [0 0]; else, P = pp.kernel_size(2:3); end; % padding
    filter_its = prod(floor((input_shape([gp.featid, gp.frameid])-pp.kernel_size+P)./pp.strides+1)); %amount of filter conv iterations
    complexity(1,gp.macid) = filter_mac*filter_its*pp.filters; %update mac
    % number of parameters
    nr_parameters = prod(pp.kernel_size)*input_shape(gp.chid)*pp.filters+pp.filters*pp.use_bias; %filter params + biases*pp.use_bias
    % additional layers to call if specified in config (following keras convention)
    if isfield(pp,'activation')
        [~, complexity_tmp, ~] = Activation(pp,gp,input_shape);
        complexity = complexity + complexity_tmp;
    end
end