function [bits2] = rz(bits2)
%nrz converts values of -1 and 1 into values of 0 and 1 respectively 
n = length(bits2);
for i = 1:n
    if bits2(i) == -1
        bits2(i) = 0;
    end
end
end