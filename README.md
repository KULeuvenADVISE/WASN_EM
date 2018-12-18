# WASN EM: a multi-layered Energy Model for Wireless Acoustic Sensor Networks

Smart sensing is expected to become a pervasive technology in smart cities and environments of the near future. These services are improving their capabilities due to significant academic and industrial interest. In effect, these services are becoming more popular due to integrated devices shrinking in size while maintaining their computational power, which can run diverse Machine Learning algorithms and achieve high performance in various data-processing tasks. 
One attractive sensor modality to be used for smart sensing are acoustic sensors, 
which can convey highly informative data while keeping a moderate energy consumption. Unfortunately, the energy budget of current wireless sensor networks is usually not enough to support the requirements of standard microphones. Therefore, energy efficiency needs to be increased at all layers - sensing, signal processing and communication - in order to bring wireless smart acoustic sensors into the market. 

To help to attain this goal, this paper introduces *WASN-EM*: an energy consumption model for wireless acoustic sensors networks (WASN), whose aim is to aid in the development of novel techniques to increase the energy-efficient of smart wireless acoustic sensors. This model provides a first step of exploration prior to custom design of a smart wireless acoustic sensor, and also can be used to compare the energy consumption of different protocols.


This repository contains the source code of the WASN Energy Model described in:

[G. Dekkers, F. Rosas, S. Lauwereins, S. Rajendran, S. Pollin, B. Vanrumste, T. van Waterschoot, M. Verhelst and P. Karsmakers, “A multi-layered energy consumption model for smart wireless acoustic sensor networks],” KU Leuven, Tech. Rep., December 2018](https://arxiv.org/abs/1812.06672).

Authors: 

- Gert Dekkers (<gert.dekkers@kuleuven.be>, <https://iiw.kuleuven.be/onderzoek/advise/People/Gert_Dekkers>)
- Fernando Rosas (<f.rosas@imperial.ac.uk>, <https://www.imperial.ac.uk/people/f.rosas>)

## Getting started

1. Clone repository from [Github](https://github.com/WASN_EM). 
2. Read the technical report: [A multi-layered energy consumption model for smart wireless acoustic sensor networks](https://arxiv.org/abs/1812.06672).
3. Run the script ``main.m``
4. Current parameters of the chain match the parameters described in a technical report. Adjust as you like!
5. Missing processing layers? **Please feel free to contribute.** The power of this model is that it could create a common ground for researchers to compare. Details on how to contribute can be found below. 

## Repository overview
    .
    ├── main.m						# main code
    ├── general/					# Folder containing the sensing model related configurations and functions
		├──── general_loadparam.m		# Function to load the general parameters of the model
		└──── params/				# Folder containing the different parameter files
			└────── default.yaml		# A default example based on the technical paper
    ├── sensing/					# Folder containing the sensing model related configurations and functions
		├──── sensing_consumption.m		# Function to calculate the energy spend in sensing
		└──── sensing_param.m			# Function containing the sensing related parameters
    ├── processing/					# Folder containing the processing related chains and layers
		├──── proc_loadparam.m			# Function to read the processing chain from the yaml file
		├──── proc_info.m			# Function to translate the chain to complexity, number of parameters and output shapes
		├──── memo_acc_stor.m			# Function to obtain memory storage and accesses given the chain
		├──── bits_to_energy.m			# Function which converts ops, bits to be stored and memory access to an energy value 
		└──── chains/				# Folder containing the processing chains
			├────── FE/			# Feature extraction chains
			├────── NN/			# Neural Network chains
			└────── ADC.yaml		# Processing chain including only a ADC layer.
		└──── layers/				# Folder containing the layers used in the chains
			├────── FE/			# Feature Extraction layers
			├────── NN/			# Neural Network layers
			├────── .../			# you can add other layers (e.g. SVM) if you want to contribute
			└────── ADC.yaml		# ADC layer to include the storage cost of the sensing layer
    ├── communication/					# Folder containing the communication model related configurations and functions
		├──── comm_consumption.m		# Function to calculate the energy spend in communicating
		├──── comm_loadparam.m			# Function to load the communication parameters of the model
		└──── params/				# Folder containing the different parameter files
			└────── default.yaml		# A default example based on the technical paper
    ├── utils/						# A folder containing utility functions 
    ├── LICENSE						# license file
    └── README.md					# Readme file

## Code summary

The file `main.m` contains the main code and consists in the following main blocks: 

- general system initialization, 
- sensing parameter loading and energy computation, 
- processing parameter loading and energy computation,
- communication parameter loading and energy computation,
- aggregation of seperate energy consumptions to compute lifetime,
- Print/plot output

**The following sections will provide a brief overview of these blocks. To know exactly what each function does please read the function help.**

### General system initialization
The code snippet below shows the first block of code provided. Here it is defined which configuration (method) is used for each of the layers in the WASN. Each of these strings refer to a parameter/chain .yaml file in each the layer's folders (e.g. ### General system initializationgeneral/params/default.yaml`). In the example code the configuration for sensing and communication is set to `default` which is the default setting provided in the document. The `general configuration` refers to parameters applicable to the entire WASN instead of just one layer. Regarding the processing layer the string also refer to a particular .yaml file (e.g. `processing/chains/FE/framelogMel.yaml). The code allows to add multiple succesive chains (e.g. proc{1}, proc{2}, ...). It could be interesting for further analysis to compare the contribution of for example the feature extraction and classification in terms of energy/complexity. These processing chains are grouped in folders to provide some overview (e.g. feature extraction and neural network). One could add additional custom folders (e.g. SVM).

	1	% -- Init system -- %
	2	% define setup
	3	gen.method = 'default'; % name of the general config file 
	4	sens.method = 'default'; % name of sensing config file
	5	proc{1}.method = 'FE/framelogMel'; % name of the first processing chain (typically FE). if no FE => 'FE/ADC'
	6	proc{2}.method = 'NN/DCASE18Task5Baseline'; % name of second processing chain (typically classifier) or remove line
	7	comm.method = 'default'; % name of communication config file
	8	% get general param
	9	gen = general_loadparam(gen.method); % get general parameters (fs, µC, ..)

Finally, at line 9 the general parameters are loaded. 

### Sensing layer model

In the following code snippet the parameters for sensing are loaded and processed to obtain a measure for energy consumption (`sens.cons` [mJ]) and an output shape vector (`sens.os`) (e.g. sampled 10 seconds at a sampling frequency of 16 kHz with one microphone channel).

	1	% -- Sensing layer -- %
	2	if verbose, disp('%%%% Sensing %%%%'); end;
	3	sens.conf = sensing_loadparam(sens.method, gen); % get sensing parameters
	4	[sens.cons, sens.os] = sensing_consumption(sens.conf, gen); % [mJ]

### Processing layer model
The following code snippet shows the estimation of the processing layer.

	1	% -- Processing layer -- %
	2	input_shape = sens.os; prev_chain = []; E_proc = []; name_proc = cell(0); %init as empty at first run
	3	for p=1:length(proc) % for each processing chain
	4	    if verbose, disp(['%%%% Processing layer: ' proc{p}.method ' %%%%']); end;
	5	    % get values
	6	    proc{p}.conf = proc_loadparam(proc{p}.method, input_shape, gen); % get params
	7	    [proc{p}.os, proc{p}.ops, proc{p}.par] = proc_info(proc{p}.conf, gen, input_shape,verbose); % get output shape, ops and nr. parameters
	8	    [proc{p}.ma, proc{p}.ms_o, proc{p}.ms_p] = memo_acc_stor(proc{p}.os, proc{p}.par, proc{p}.ops, proc{p}.conf, prev_chain, gen,verbose); % get memory used in storing ops/params
	9	    [proc{p}.cons.all,proc{p}.cons.op,proc{p}.cons.ms_o,proc{p}.cons.ms_p,proc{p}.cons.ma] = bits_to_energy(proc{p}.ma, proc{p}.ms_o, proc{p}.ms_p, proc{p}.ops, gen); % energy consumption
	10	    % keep from previous chain
	11	    input_shape = proc{p}.os(end,:);
	12	    prev_chain = proc{p}.conf;
	13	end

The code can be summarised in the following steps:

- Parameters are loaded by the function `proc_loadparam.m`,
- computational complexity, number of parameters and memory access are calculated based on the chain (`proc_info.m`),
- number of parameters and memory accesses are converted to an amount of bits for a particular memory (`memo_acc_stor.m`), 
- given previous information a final energy value is obtained (`bits_to_energy.m`), and
- finally, the output shape of the last processed layer and its configuration is retained and given to next layer (in a loop).

### Communication layer model
In the following code snippet the parameters for communication are loaded and processed to obtain a measure for energy consumption (`sens.cons` [mJ]). In this example no information is received.

	1	% -- Communication layer -- %
	2	if verbose, disp('%%%% Communication %%%%'); end;
	3	comm.conf = comm_loadparam(comm.method,gen); % get comm params
	4	comm.conf.N_T = prod(input_shape)*gen.S; % informative bits to communicate
	5	comm.conf.N_R = 0; % informative bits to receive
	6	comm.cons = sum(comm_consumption(comm.conf,sens.conf,gen)); 

### How to design custom processing chains

The code consists of a set of commonly used processing layers. These layers (e.g. FE/FFT_1D_Radix2 and NN/Conv2D) can be used to form your own custom processing chain you want to acquire an energy/complexity estimation from. A typical configuration file of such a chain is set up as follows:

	1	constants:
	2	  variable1: value1	# hardcoded values
	3	  variable2: value2	# ..
	4	  variable3: value3	# ..
	5	  fs_audio: NaN		# parameter by string reference overloading
	6	  T: NaN		# ..
	7	  channels: NaN		# ..
	8	  S: NaN		# ..
	9	
	10	chain:
	11	  - class_name: ADC		# layer name (string name of behaviour function) 
	12	    config:			# layer parameters
	13	      fs: FS			# parameter by string reference
	14	      window_size: T		# ..
	15	      channels: CHANNELS	# ..
	16	    memory: {parameters: 1/2/..., output: 1/2..., output_save: True/False}	# optional
	17		wordsize: S																# optional
	18	  - class_name: layer2  
	19	    config:
	20	      variable2_1: variable1			# parameter by string reference
	21		  variable2_2: variable2*FS		# equation using parameter by string reference
	22		  variable2_3: (variable1*variable2)/2	# ..

A typical configuration file consists of two branches. 

The most important one is the `chain` branch. The branch describes the chain using a list kind of structure. For each item in the list one can define a processing layer to be used (e.g. ADC and Conv2D). Note that the first layer in the first processing chain should always be an ADC to include memory storage and accesses of that data. Each layer consists of three main parts:

- class_name: name of the processing layer you want to use. It refers to the name of the behaviour function available in `layers\..`.
- config (OPTIONAL): structure containing variables relevant to the processing chain (e.g. stride of convolutional layer).
- memory (OPTIONAL): 
	- parameters: memory index of where the parameters should be stored
	- output: memory index of where the output should be stored 
	- output_save: `if True` memory is reserved for the output, `if False` no new memory is reserved and uses the memory location of the output of the previous layer. The amount of values should be less or equal and it should be possible to have in-place computation.
- wordsize (OPTIONAL): wordsize of the parameters and output on the memory.

Note that the only mandatory field is the `class_name`. If no config is given this simply means that that particular layer does not need any configuration and that should match with the behaviour function. For the other fields a default value will be used. This is defined in `general/params/default.yaml`

The second branch, `constants` is optional but can be handy. These variable strings (e.g. lines 2-8) can be reused throughout the chain as a reference (e.g. lines 13-15, 16 and 20) or in equations (lines 21 and 22). A configuration file of a processing chain is loaded via the function call `chain = proc_loadparam(chain_str,input_shape,gen)` where `chain_str` refers to the name of the chain (e.g. `FE/framelogMel`), `input_shape` a vector of size three giving the size of the input to that layer and finally `gen` a struct containing general configuration parameters (loaded by `general/general_loadparam.m`). Fields in the `gen` struct matching the string of variables in the `constants` branch will get overloaded. This could be usefull to overload often used reused parameters (e.g. sampling frequency of the audio).

In theory you could combine both feature extraction and classification in one chain. However, for analytic purposes one could also seperate both as explained in section `Processing layer model`.

## How to contribute a processing layer

The behaviour of a particular layer is put into a function. Each function has a uniform structure and input to cope with the rest of the code. The following code snippet shows an example of the behaviour model of an 1D FFT radix2:
	
	1	% ----------------------------------------------------------------------
	2	%  FFT 1D radix2 behaviour model
	3	%
	4	%  Section 4.1.2
	5	%
	6	%  Author: Gert Dekkers, KU Leuven
	7	% ----------------------------------------------------------------------
	8	% Syntaxis: [output_shape, complexity, nr_parameters] = FFT_1D_Radix2(pp,gp,input_shape)
	10	% Inputs:
	11	% (1) pp                output shape of the layer given an input shape and parameters
	12	% (2) gp                complexity of the layer given an input shape and parameters
	13	% (3) input_shape       number of parameters of the layer given an input shape and parameters
	14	% Outputs:
	15	% (1) output_shape      output shape of the layer given an input shape and parameters
	16	% (2) complexity        complexity of the layer given an input shape and parameters
	17	% (3) nr_parameters     number of parameters of the layer given an input shape and parameters
	18	%
	19	% Usage example (chain):
	20	%   - class_name: FFT_1D_Radix2
	21	%   does not contain any parameters 
	22	
	23	function [output_shape, complexity, nr_parameters] = FFT_1D_Radix2(pp,gp,input_shape)
	24	    % var inits
	25	    output_shape = zeros(1,gp.nr_dimensions);
	26	    complexity = zeros(1,gp.nr_arop);
	27	    %nr_parameters = zeros(1,1);
	28	    % output shape
	29	    output_shape(1,[gp.chid gp.frameid]) = input_shape(1,[gp.chid gp.frameid]);
	30	    output_shape(1,gp.featid) = ((2^nextpow2(input_shape(1,gp.featid)))/2 + 1)*2; %complex output first half of spectrum
	31	    % complexity
	32	    N = output_shape(1,gp.featid); % fft size
	33	    complexity(1,gp.multid) = N/2*nextpow2(N)*4; 
	34	    complexity(1,gp.addid) = N/2*nextpow2(N)*2 + N*nextpow2(N)*2;
	35	    complexity(1,:) = complexity(1,:)*output_shape(1,gp.frameid); %multpl by frames
	36	    % number of parameters
	37	    nr_parameters = 1/2*output_shape(1,gp.featid); % twiddle   
	38	end

Such a function has three main parts: a) computation of output shape, b) computation of complexity and c) computation of amount of parameters. All of these outputs rely on parameters set in the processing chains (which are accesible via the `pp` struct). In- and output shapes have a size of three where these values represent the amount of channels/filters, amount of features and amount of time indices or frames. Over all chains you should always follow the same convention (the ordering is not changed on a layer by layer basis!). The ordering is controlled in the general config.

**If you would contribute a layer please make sure you follow the example. Also, it would be nice if you could place a reference to some documentation to let others verify the content. If during creating your own processing layer you miss some functionality, let us know.** 

## Changelog

#### 1.0.0 / 2018-12-07

* First public release

## License

When using the script for research one should refer to the following paper:

G. Dekkers, F. Rosas, S. Lauwereins, S. Rajendran, S. Pollin, B. Vanrumste, T. van Waterschoot, M. Verhelst and Peter Karsmakers, “A multi-layered energy consumption model for smart wireless acoustic sensor networks],” KU Leuven, Tech. Rep., December 2018.

The script is released under the terms of the [MIT License](https://github.com/WASN_EM/LICENSE).
