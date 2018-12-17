% ----------------------------------------------------------------------
%  Dropout behaviour model
%
%   Based on keras definition: https://keras.io/layers/core/#dropout
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = Dropout(pp,gp,input_shape)
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
%   - class_name: Dropout
%     No parameters needed

function [output_shape, complexity, nr_parameters] = Dropout(pp,gp,input_shape)
    % var inits
    %output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    nr_parameters = zeros(1,1);
    % If certain params are not specified, fill them up
    % /
    % output shape
    output_shape = input_shape;
    % complexity
    % /
    % number of parameters
    % /
end