%Gian Angelo Tria
%ECE 408: Wireless Comms 
%2/23/2020
%Prof. Hoerning 
%WCDMA Physical Downlink
%% 
clc; clear all; close all;
%Initiate Data And Parameters
numbits = 1000; %Number of bits being sent
data_in = randi([0 1],numbits,1); %Random binary bits
samples_per_frame = 10; %Initializing samples per frame for OVSF
spreading_factor = 64; %Spreading factor for OVSF
N_ary = 2; %Binary 
SNR_range = linspace(.1,10,100); %Range of SNR to test
index = 1; %index used during for loop to plot for each iteration 

numerrs = zeros(1,length(SNR_range));
pcterrs = zeros(1,length(SNR_range));

for k = SNR_range
SNR = k;
%scramble
scrambler = comm.Scrambler(N_ary,'1 + z^-2 + z^-3 + z^-5 + z^-7', ...
    [0 0 0 0 0 0 1]);   %Scrambler Polynomial with inital value
scrambled = scrambler(data_in); %scrambling data in

%nrz
unspread = nrz(scrambled); %nrz function changes 0's and 1's to -1's and 1's respectively

%Spreading OVSF
m = length(unspread); 
hOVSF = comm.OVSFCode('SamplesPerFrame',samples_per_frame,'SpreadingFactor',spreading_factor);
    seq = step(hOVSF); %generate ovsf spreading code 
for i = 1:m
    for j = 1:samples_per_frame
        new_data((i-1)*samples_per_frame+(j)) = unspread(i); %need samples per frame number of bits for ever data point
    end
end
ovsf_code = repmat(transpose(seq),1,m); %change size so that the matricces are the same size 
spread = new_data.*ovsf_code; %elementwise multiplication to apply the OVSF spreading code

%convert to binary
newspread = rz(transpose(spread)); %convert back into bits of 0's and 1's to be modulated

%QPSK Modulation
qpsk = QPSK(newspread); %used QPSK function to modulate

%Adding AWGN to QPSK 
noisy(:,index) = awgn(qpsk,SNR);%passing QPSK modulated signal through an AWGN channel

%Demodulation
spread_2 = QPSKdemod(noisy(:,index));%Using QPSKdemod function to demodulate 

%nrz
spread_3 = nrz(spread_2); %Need to changes 0's and 1's to -1's and 1's respectively to use OVSF

%Unspreading OVSF
unspread = transpose(ovsf_code).*spread_3;  %reapplying spreading code using elementwise multiplication
unspread_2 = reshape(unspread,samples_per_frame,numbits); %reshaping into columns for each unique data bit
mean_unspread = mean(unspread_2); %taking the mean of each column
scrambled_2 = transpose(mean_unspread > 0); %logical operator used to decide between 0 and 1

%unscramble
descrambler = comm.Descrambler(N_ary,[1 0 1 1 0 1 0 1], ...
    [0 0 0 0 0 0 1]); %the same polynomial and initial conditions, just written differently
data_out = descrambler(scrambled_2); %unscrambling the data

%Calculating Bit Error Rate

[numerrs(1,index),pcterrs(1,index)] = biterr(data_in,data_out); % Number and percentage of errors
index = index + 1; %iterating for a new numerr and pcterr for the for loop
end

scatterplot(noisy(:,1));
title('QPSK with minimum SNR')

scatterplot(noisy(:,length(SNR_range)));
title('QPSK with Maximum SNR')

figure
stem(scrambled,'Color','red','LineWidth',.5)
xlim([(1 - (numbits/10)),(numbits + (numbits/10))])
ylim([-2 2])
title('Scrambled Code')
xlabel('bit')
ylabel('bit value')

figure
stem(ovsf_code,'Color','green','LineWidth',.5)
xlim([(1 - (numbits*samples_per_frame/10)),(numbits*samples_per_frame + (numbits*samples_per_frame/10))])
ylim([-2 2])
title('OVSF Code')
xlabel('bit')
ylabel('bit value')

figure
stem(spread,'Color','blue','LineWidth',.5)
xlim([(1 - (numbits*samples_per_frame/10)),(numbits*samples_per_frame + (numbits*samples_per_frame/10))])
ylim([-2 2])
title('Spread Code')
xlabel('bit')
ylabel('bit value')

figure
plot(SNR_range,pcterrs)
title('Percent Bit Error Rate')
xlabel('SNR')
ylabel('Bit Error Rate')