%Esta funcion calcula la integral de la señal 

function output= IEMG(N,ventanaactual)
    output= (sum(abs(ventanaactual))); 
end