% ----------------------------------------------------------------------
%  Time-domain framing behaviour model
%
%  Section 4.1.1
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = tdframing(pp,gp,input_shape)
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
%   - class_name: tdframing
%     config:
%       window_size: 30/1000*16000 % samples
%       step_size: 10/1000*16000 % samples

function [output_shape, complexity, nr_parameters] = tdframing(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    nr_parameters = zeros(1,1);
    % output shape
    output_shape(1,:) = [input_shape(1,1) pp.window_size floor((input_shape(1,gp.frameid)-pp.window_size+pp.step_size)/pp.step_size)];
    % complexity
    % /
    % number of parameters
    % /
end

