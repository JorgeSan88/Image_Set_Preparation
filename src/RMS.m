function  output = RMS(ventanaactual,numdatos)
%Valor RMS
%Calcula el valor RMS de una ventana

 output = sqrt((sum(ventanaactual.^2))/numdatos);

end

