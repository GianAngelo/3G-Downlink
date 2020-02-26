function [modData] = QPSKdemod(data)
% Create a QPSK modulator System object with bits as outputs and Gray-coded signal constellation
       qpsk_mod = comm.QPSKDemodulator('BitOutput',true);
% Demodulate the data using the demodulator object 
       modData = step(qpsk_mod,data);
end 