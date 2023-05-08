%This function calculates the value of the moment two of the input window


function output = moment2(N,Current_window)

output = sum((diff(Current_window)).^2); 

end