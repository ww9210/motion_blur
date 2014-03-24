function dataout=mydataread(filein,fileout,line)
fidin=fopen(filein,'r');
fidout=fopen(fileout,'w');
nline=1;
while true %
tline=fgetl(fidin); %
%format = strcat('%s',char(13,10));
fprintf(fidout,'%s',tline);
fprintf(fidout,'\n');
nline=nline+1; 
if nline>line
    dataout=1;
break;
end
end
fclose(fidin);
fclose(fidout);