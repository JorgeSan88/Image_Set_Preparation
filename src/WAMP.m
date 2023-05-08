function output = WAMP(numdatos,ventanaactual,umbral)
salida=0; 
for k=1:numdatos-1

    a= ventanaactual(k);
    b= ventanaactual(k+1);
    c= abs(a-b);
    if c > umbral
        salida= salida+1;
    end
end

output=salida;

