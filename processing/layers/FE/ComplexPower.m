% ----------------------------------------------------------------------
%  Complex power behaviour model
%
%  Take the power of a complex number
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = ComplexPower(pp,gp,input_shape)
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
%   - class_name: ComplexPower
%     No parameters needed

function [output_shape, complexity, nr_parameters] = ComplexPower(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    nr_parameters = zeros(1,1);
    % output shape
    output_shape = input_shape;
    output_shape(1,gp.featid) = input_shape(1,gp.featid)/2;
    % complexity
    complexity(1,gp.multid) = prod(output_shape)*2; %a²+b²
    complexity(1,gp.addid) = prod(output_shape); 
    % number of parameters
    % /
end

