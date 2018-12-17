% ----------------------------------------------------------------------
%  Neural Network Activation behaviour model
%
%   Document: section 4.2.2
%   Based on keras definition: https://keras.io/activations/
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = Activation(pp,gp,input_shape)
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
%   - class_name: Activation
%     config:
%       activation: relu/softmax %pick one

function [output_shape, complexity, nr_parameters] = Activation(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    nr_parameters = zeros(1,1);
    switch pp.activation 
        case 'relu'
            % output shape
            output_shape = input_shape;
            % complexity
            complexity(1,gp.compid) = complexity(1,gp.compid) + prod(input_shape); %update comp
            % number of parameters
            % /
        case 'softmax'
            % output shape
            output_shape = input_shape;
            % complexity
            complexity(1,gp.divid) = complexity(1,gp.divid) + prod(input_shape); %update div
            complexity(1,gp.expid) = complexity(1,gp.expid) + prod(input_shape); % "" exp
            complexity(1,gp.addid) = complexity(1,gp.addid) + prod(input_shape); % "" add
            % number of parameters
            % /
    end
end