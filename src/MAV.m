%Esta funcion calcula el valor medio absoluto de N cantidad de datos de la
%variable 'a'

function output= MAV(N,ventanaactual)
    output= (sum(abs(ventanaactual)))/N; 
end
