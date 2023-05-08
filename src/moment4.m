%This function calculates the value of the moment four of the input window

function output = moment4(N,Current_window)

output = sum((diff(diff(Current_window))).^2); 

end