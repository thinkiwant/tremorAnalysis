function output  = myZerophaseFilt(input) %#codegen

[B,A] = butter(20,0.314);
output = filtfilt(B,A,input);

end