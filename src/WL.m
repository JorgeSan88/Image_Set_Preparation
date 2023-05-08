function output = WL(ventana,numdatos)
e=0;
for k=1:numdatos-1
     e(k)=abs(ventana(k+1)-ventana(k));
end
output=sum(e);
end
