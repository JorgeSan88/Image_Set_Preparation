%This function calculates the value of the zero moment of the input window


function output = moment0(N,Current_window)

    output = sum(abs(Current_window).^2);
end