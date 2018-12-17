% ----------------------------------------------------------------------
%  FFT 1D radix2 behaviour model
%
%  Section 4.1.2
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = FFT_1D_Radix2(pp,gp,input_shape)
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
%   - class_name: FFT_1D_Radix2
%   does not contain any parameters 

function [output_shape, complexity, nr_parameters] = FFT_1D_Radix2(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    %nr_parameters = zeros(1,1);
    % output shape
    output_shape(1,[gp.chid gp.frameid]) = input_shape(1,[gp.chid gp.frameid]);
    output_shape(1,gp.featid) = ((2^nextpow2(input_shape(1,gp.featid)))/2 + 1)*2; %complex output first half of spectrum
    % complexity
    N = output_shape(1,gp.featid); % fft size
    complexity(1,gp.multid) = N/2*nextpow2(N)*4; 
    complexity(1,gp.addid) = N/2*nextpow2(N)*2 + N*nextpow2(N)*2;
    complexity(1,:) = complexity(1,:)*output_shape(1,gp.frameid); %multpl by frames
    % number of parameters
    nr_parameters = 1/2*output_shape(1,gp.featid); % twiddle   
end