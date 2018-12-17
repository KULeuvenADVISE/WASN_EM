% ----------------------------------------------------------------------
%  Dense behaviour model
%
%   Document: section 4.2.4
%   Based on keras definition: https://keras.io/layers/pooling/
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = Dense(pp,gp,input_shape)
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
%   - class_name: Dense
%     config:
%       units: 12 # amount of neurons
%       activation: softmax/relu % optionally you could add an activation to the chain. Not mandatory.
      
function [output_shape, complexity, nr_parameters] = Dense(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    % nr_parameters = zeros(1,1);
    % output shape
    output_shape(1,[gp.chid gp.featid, gp.frameid]) = [pp.units 1 1]; %get output shape
    % complexity
    complexity(1,gp.macid) = (prod(input_shape)+1)*pp.units; %update mac, input_length+bias * output_length
    % number of parameters
    nr_parameters = (prod(input_shape)+1)*pp.units; %outputs x input + biases
    % additional layers to call if specified in config (following keras convention)
    if isfield(pp,'activation')
        [~, complexity_tmp, ~] = Activation(pp,gp,input_shape);
        complexity = complexity + complexity_tmp;
    end
end