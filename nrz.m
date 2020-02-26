function [bits] = nrz(bits)
%nrz converts values of 0 and 1 into values of -1 and 1 respectively 
n = length(bits);
for i = 1:n
    if bits(i) == 0
        bits(i) = -1;
    end
end
end