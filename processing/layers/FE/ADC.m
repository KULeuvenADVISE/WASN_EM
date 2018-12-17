% ----------------------------------------------------------------------
%  ADC behaviour model
%
%  Not specified in document. Should be used as initial layer to include 
%  memory impact for the sensing layer.
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
%   - class_name: ADC
%     config:
%       fs: 16000 % Hz
%       window_size: 10 % seconds
%       channels: 4 % microphone channels

function [output_shape, complexity, nr_parameters] = ADC(pp,gp,input_shape)
    % Inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    nr_parameters = zeros(1,1);
    % output shape
    output_shape(1,[gp.chid gp.featid gp.frameid]) = [pp.channels 1 pp.window_size*pp.fs]; 
    % complexity
    % /
    % number of parameters
    % /
end

