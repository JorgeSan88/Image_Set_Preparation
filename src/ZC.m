%Funcion que obtiene los cruces por cero
 function output = ZC(ventana,numdatos,umbral)
 e=0;
 for k=1:numdatos-1
     if ((ventana(k)>0&ventana(k+1)<0)|(ventana(k)<0&ventana(k+1)>0))&((abs(ventana(k+1)-ventana(k))>=umbral))
         e=e+1;
     end
 end
 output=e;
 end