function   [datos_normalizados,valores_minimos,valores_maximos] = normalizacion_imagen(minimo,maximo,datos)

% Esta Funcion realiza una normalizacion de datos a un rango dentro de un
% minimo y maximo
%[datos_normalizados,valores_minimos,valores_maximos] = normalizacion(minimo,maximo,datos)
% minimo- es un valor numerico escalar 
% maximo- es un valor numerico escalar 
% datos- puede ser un vector o una matriz de datos
%datos_normalizados- devuelve la matriz "datos" normalizada a valores de
                     %entre 'minimo' y 'maximo'
%valores_maximos- devuelve los valores maximos de cada entrada (vector) de la matriz
                  %de datos
%valores_minimos- devuelve los valores minimos de cada entrada (vector) de la matriz
                  %de datos
%JSandoval.

                   
datos = datos;
valores_maximos = max(max(datos));
valores_minimos = min(min(datos));

[l,c]= size(datos);  
datos_normalizados = ((maximo-minimo)*((datos- valores_minimos))./(valores_maximos-valores_minimos))+ minimo;
%datos_normalizados = datos_normalizados';