% ----------------------------------------------------------------------
%  Script which estimates the energy consumption, battery lifetime and
%  needed computational resource of a smart audio sensor chain. 
%  The chain includes sensing, processing and wireless communication. 
%
%  The model is fully described in the following paper:
%   G. Dekkers, F. Rosas, S. Lauwereins, S. Rajendran, S. Pollin, B. Vanrumste, T. van Waterschoot, M. Verhelst and Peter Karsmakers, 
%   “A multi-layered energy consumption model for smart wireless acoustic sensor networks,” KU Leuven, Tech. Rep., December 2018.
%  Please refer to this paper when using this model for your research.
%
%  Authors: 
%   Gert Dekkers, KU Leuven
%   Fernando Rosas, Imperial College London
% ----------------------------------------------------------------------

clc; clear;
addpath(genpath(pwd))

%% Code for acquiring energy consumption for a single estimate (network node)
verbose = 1; %0: show final output, 1: show all

% -- Init system -- %
% define setup
gen.method = 'default'; % name of the general config file 
sens.method = 'default'; % name of sensing config file
% proc{1}.method = 'ADC';
proc{1}.method = 'FE/framelogMel'; % name of the first processing chain (typically FE). if no FE => 'FE/ADC'
proc{2}.method = 'NN/CNN_1D_example'; % name of second processing chain (typically classifier) or remove line
comm.method = 'default'; % name of communication config file
% get general param
gen = general_loadparam(gen.method,[]); % get general parameters (fs, µC, ..)

% -- Sensing layer -- %
if verbose, disp('%%%% Sensing %%%%'); end;
sens.conf = sensing_loadparam(sens.method, [], gen); % get sensing parameters
[sens.cons, sens.os] = sensing_consumption(sens.conf, gen); % [mJ]

% -- Processing layer -- %
input_shape = sens.os; prev_chain = []; E_proc = []; name_proc = cell(0); %init as empty at first run
for p=1:length(proc) % for each processing chain
    if verbose, disp(['%%%% Processing layer: ' proc{p}.method ' %%%%']); end;
    % get values
    proc{p}.conf = proc_loadparam(proc{p}.method, [], input_shape, gen); % get params
    [proc{p}.os, proc{p}.ops, proc{p}.par] = proc_info(proc{p}.conf, gen, input_shape,verbose); % get output shape, ops and nr. parameters
    [proc{p}.ma, proc{p}.ms_o, proc{p}.ms_p] = memo_acc_stor(proc{p}.os, proc{p}.par, proc{p}.ops, proc{p}.conf, prev_chain, gen,verbose); % get memory used in storing ops/params
    [proc{p}.cons.all,proc{p}.cons.op,proc{p}.cons.ms_o,proc{p}.cons.ms_p,proc{p}.cons.ma] = bits_to_energy(proc{p}.ma, proc{p}.ms_o, proc{p}.ms_p, proc{p}.ops, gen); % energy consumption
    % keep from previous chain
    input_shape = proc{p}.os(end,:);
    prev_chain = proc{p}.conf;
end

% -- Communication layer -- %
if verbose, disp('%%%% Communication %%%%'); end;
comm.conf = comm_loadparam(comm.method,[],gen); % get comm params
comm.conf.N_T = prod(input_shape)*gen.S; % informative bits to communicate
comm.conf.N_R = 0; % informative bits to receive
comm.cons = sum(comm_consumption(comm.conf,sens.conf,gen)); 

% -- Final output -- %
fc = prep_chain_info(sens,proc,comm,gen); % get everything in proper format to plot/print
print_chain_info(fc) % Print energy distribution of the full sensor network
plot_energy_proc(proc) % Plot energy distribution of particular layers in the processing chain
print_mem_cycle(proc,gen) % Print needed cycli/s and mem storage