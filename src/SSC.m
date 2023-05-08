%SSC(cambio de la pendiente)Es el cambio de signo de la pendiente de la señal y proporciona una medida de la
%frecuencia [13]. Debe de introducirse un umbral para evitar el ruido. 
function output = SSC(ventana,numdatos,umbral)
e(numdatos)=0;
for k=1:numdatos-2
    if (( (ventana(k+1)>ventana(k)) & (ventana(k+1)>ventana(k+2)) ) |  ((ventana(k+1)<ventana(k)) & (ventana(k+1)<ventana(k+2))))   &   ((abs(ventana(k+1)-ventana(k+2))>= umbral) | (abs(ventana(k+1)-ventana(k))>umbral))
        e(k)=1;
    else
        e(k)=0;
    end
end
output=sum(e);
end