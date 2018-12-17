% ----------------------------------------------------------------------
%  Neural Network Batch Normalization behaviour model
%
%   Document: section 4.2.5
%   Based on keras definition: https://keras.io/layers/normalization/
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = BatchNormalization(pp,gp,input_shape)
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
%   - class_name: BatchNormalization
%     config:
%       axis: number # axis used to do batch norm on


function [output_shape, complexity, nr_parameters] = BatchNormalization(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    %nr_parameters = zeros(1,1);
    % output shape
    output_shape = input_shape;
    % complexity
    complexity(1,gp.addid) = prod(input_shape);
    complexity(1,gp.multid) = prod(input_shape);
    % number of parameters
    nr_parameters = 2*input_shape(pp.axis); %mean and var
end