function [modData] = QPSK(data)
 % Create a QPSK modulator System object with bits as inputs and Gray-coded signal constellation
       qpsk_mod = comm.QPSKModulator('BitInput',true);
 % Modulate
       modData = step(qpsk_mod,data);
end