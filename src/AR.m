function output = AR(ventanaactual,orden)
%Funcion del modelo de autoregresion
%  Determina los coeficientes del modelo AR de la ventana actual

coeficientes = arcov(ventanaactual, orden);
output = coeficientes(1,2:orden+1);

end

