function [E, E_bit, X, tau, Reff, Pirr_dBm] = comm_consumption(pc,ps,pg)
% ----------------------------------------------------------------------
%  Function which calculates the energy consumed for sensing audio data. 
%  Author: Fernando Rosas, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: comm_consumption(pc,ps,pg)
% Inputs:
% (1,2,3) pc,ps,pg      struct containing all params of communication, sensing and general resp.
% Outputs:
% (1) E - total energy consumed by the transceiver/receiver [Etx,Erx] [mJ]
% (2) E_bit - total energy consumed by the transceiver/receiver per data bit [Etx,Erx] [mJ]
% (3) X - vector which contains the percentage of the total consumption of
% the transceiver corresponding to X(1): startup, X(2): encoding, X(2): electronic components involved
% in the forward transmisison, X(3): electronic components involved in the
% feedback transmissions, X(4): PA.
% (4) Tau - average number of transmission trials until a frame is
% correctly decoded in the receiver
% (5) Reff - Effective data rate [bits/s]
% (6) Pirr_dBm - Irradiated power [dBm]

% load parameters
v2struct(pc); % expand field to workspace
v2struct(ps); % expand field to workspace
v2struct(pg); % expand field to workspace

% general things
b = log2(M);                                                                % number of bits per simbol
omega = 1;                                                                  % no multiplexion

%% Encoding/decoding
n = L;
m = ceil(log2(n+1));
k = n-t*m;
r = k/L;
% consumption
Eenc = 0;
% (for now we just neglect the Tx encoding for BCH codes) - section 5.3
Nadd  = (2*n-1)*t + 2*t^2;
Nprod =     2*n*t + 2*t^2;
Edec =  Eop * (Nadd * c(addid) + Nprod * c(multid));


%% times per bit
Tb = 1/(r*Rs) * (1/b + H/L + (Oa+Ob)/L);                                    % [s] - eq. 17
Tfb= F/(r*Rs*L);                                                            % [s] - eq. 18

%% consumption of electric components
Pdac_tx = .5* ( Vdd_dac*I0_dac*(2^n1 -1) + n1*Cp_dac*fs_DAC*Vdd_dac^2);     % [mW] - eq. 34
Padc_rx =  2^n2 * fs_ADC * FOMadc;                                          % [mW] - eq. 10
Petx = Pdac_tx + 2*Pfilter + Plo + Pmixer;                                  % [mW] - eq. 31 (partial)
Perx  = 3*Pfilter + Plna_rx + Plo + Pmixer + Pvga + Padc_rx;                % [mW] - eq. 32 (partial)
Eetx_b = Petx * Tb;                                                         % [mJ]
Eetx_fb = Petx * Tfb;                                                       % [mJ]
Eerx_b = Perx * Tb;                                                         % [mJ]
Eerx_fb = Perx * Tfb;                                                       % [mJ]

%% Calculating the constant "A" and PA consumption
if M == 2                                                                   % Peak-to-average power ratio
    PAPR=1;
else
    PAPR =  3 * (sqrt(M)-1)/(sqrt(M)+1);
end

c=3*10^8;                                                                   % Speed of light [m/s]
lambda=c/fc;                                                                % Wavelength [m]
A0 = 1/(Gt*Gr) * (4*pi/lambda);                                             % Free space attenuation at 1 meter - eq. 25

if PA == 0     % if ClassA PA - eq. 21
    beta = 1;
    eta_eff  = 0.5;
elseif PA == 1 % if ClassB PA - eq. 22
    beta = 0.5;
    eta_eff  = 0.785;
end

k = 1.3806488 * 10^-23;                                                     % Boltzmann constant [m^2 kg / s^2 K]
T_K = T_C+273;                                                              % Room temperature [K]
N0 = 10*log10(k*T_K*10^3);                                                  % Noise spectral density [dBm]
Pnoise = N0 + 10*log10(W) + Nf + Ml;                                        % Total noise power [dBm] - section 5.1
Pnoise_abs = 10^(Pnoise/10);                                                % Total noise power [mW] - section 5.1
A = (PAPR/Spa)^beta * Pnoise_abs * A0 / eta_eff;                            % [mW]

EbN0_abs = 10^(e/10); 
SNR_abs = b*EbN0_abs;
Ppa = A * omega * d^a * SNR_abs;                                            % [mW]
Epa_b = Ppa * Tb;                                                        	% [mJ]
Epa_fb = Ppa * Tfb;                                                         % [mJ]

%% Retransmission statistics
ws = v2struct;
[qx, tau] = errors(ws); % section 5.4

%% Prepare output
% energy consumption forward information frame
Etx_bit(1) = Est/((1-qx)*N_T) + Eenc + (Eetx_b + Epa_b + Eerx_fb)*tau;      % [mJ] - eq. 14
Etx = Etx_bit*N_T;
% energy consumption backward information frame
Erx_bit = Est/((1-qx)*N_R) + (Edec + Eerx_b + Eetx_fb + Epa_fb)*tau;      % [mJ] - eq. 15
Erx = Erx_bit*N_R;
% effective output bandwidth
Ttotal = (Tb + Tfb)*tau;
Reff = 1/Ttotal; 
% power distribution components forward information frame
Xtx = [Est/((1-qx)*N_T), Eenc,      Eetx_b*tau, Eerx_fb*tau, Epa_b*tau]/Etx_bit;
Xrx = [Est/((1-qx)*N_R), Edec*tau,  Eerx_b*tau, Eetx_fb*tau, Epa_fb*tau]/Erx_bit;
% Irradiated power   
Pirr = (Spa/PAPR)^beta * eta_eff * Ppa;
Pirr_dBm = 10*log10(Pirr);
% Combine
if N_R==0, Erx=0; Erx_bit=0; Xrx = zeros(size(Xrx)); end;
if N_T==0, Etx=0; Etx_bit=0; Xtx = zeros(size(Xtx)); end;
E = [Etx Erx];
E_bit = [Etx_bit Erx_bit];
X = [Xtx; Xrx];
end


function [ qx, tau] = errors(ws)
v2struct(ws) % expand field
if strcmp(ch_correlation ,'ff')
    mod = 0;
    M_header = 2; % header symbols use BPSK
    Ph = Pbit(e,M_header,channel,K);
    Pb  = Pbit(e,M,channel,K);
        
    P_BCH = 0;
    for j=0:t
        %  Pb_BCH(i,:)=Pb_BCH(i,:)+(factorial(n)/(factorial(j)*factorial(n-j)))*Pb.^j.*(1-Pb).^(n-j);
        P_BCH = P_BCH + nchoosek(n,j) * (1-Pb)^(n-j) * Pb^j;
    end
    
    P_correct_frame = (1 - Ph)^H * P_BCH;
    tau = 1 / P_correct_frame;
    qx = 0; %outage probability   
elseif strcmp(ch_correlation ,'static')
    tau = 1;
    qx = 0; %outage probability
end
end

function P = Pbit(e,M,channel,K)
%
% ---------------------------------------------------------------------
%  Function to calculate the EXACT bit error rate of M-QAM modulations
%
% Pawgn(e,M, channel, K) 
% e: EbN0,
% M: M-ary number,
% channel: 0 -AWGN, 1 - Rayleigh, 3-Nakagami-M,
% K: Nakagami-M parameters (works fine until K larger than 35). Note that
% the performance is much faster if K is an integer.
%

EbN0 = 10^(e/10);

if M == 2
    
    if channel == 0
        P=.5*erfc(sqrt(abs(EbN0)))';
    elseif channel == 1
        P=0.5*(1-sqrt((EbN0)./(1+(EbN0))));

    elseif channel == 3
        
        paso=0.01;
        theta=0:paso:pi/2;
        SNR=EbN0'*ones(size(theta));
        Theta=ones(size(e))'*theta;
        a = 1;
        c = 1;        
        H=K;
        b = log2(M);
        F = ( 1 + a*b*SNR./(H*sin(Theta).^2) ) .^-H;
        P = (c/pi)* sum(F,2) * paso;
    
    end
    
    
else
    
    upbound1 = .5*log2(M);
    Pcases = zeros(upbound1,1);
    
    for k = 1: upbound1
        
        
        upbound2 = ( 1 - 2^-k )* sqrt(M) - 1;
        F = zeros(upbound2+1,1);
        for i = 0: upbound2
            
            arg = i*2^(k-1)/sqrt(M);
            w = (-1)^floor(arg) * ( 2^(k-1) - floor(arg + .5) );
            
            if channel == 0
                
                arg1 = sqrt( 3*log2(M)*EbN0 / ( 2*(M-1) ));
                F(i+1) = w * erfc( (2*i + 1) * arg1);
                
            elseif channel == 1
                
                %arg1 = 3*(2*i+1)^2 *log2(M)*EbN0 / (2*(M-1));
                arg1 = 2*(M-1) / ( 3*(2*i+1)^2 *log2(M)*EbN0 );
                G = sqrt( 1/ (1 + arg1) );
                F(i+1) = w * ( 1 - G);
                
            elseif channel == 3
                
                a = 3 *(2*i+1)^2 * log2(M)/(2*(M-1));
                
                if K == round(K)
                    
                    H = zeros(K,1);
                    for j = 0:K-1
                        arg = K/(a*EbN0);
                        arg1 = (1 + arg)^(-j-.5) +1;
                        H(j+1) = (-1)^j * nchoosek(K-1,j) * arg1 / (2*j+1);
                    end
                    arg0 = sum(H);
                    
                    G = 1 - gamma(K+.5)/(gamma(K)*sqrt(pi)) * arg0;
                    
                else
                    
                    arg0 = a*EbN0/K;
                    arg1 = hypergeom( [.5, K+.5], 3/2, -arg0);
                    G = .5 - gamma(K+.5)/(gamma(K)*sqrt(pi)) * sqrt(arg0) * arg1;
                    
                end
                
                F(i+1) = 2 * w * G;
            end
        end
        Pcases(k) = 1/sqrt(M) * sum(F);
    end
    P = 1/upbound1 * sum(Pcases);
end
end