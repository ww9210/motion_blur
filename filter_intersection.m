function histo_matrix = filter_intersection(blur_length,phi)

%% debug only
%blur_length=10;
%phi=-78;
if (phi~=90)
    %%filter_intersection
    phi = mod(phi,180)/180*pi;
    partition_number = 10000;
    
    
    sinphi= sin(phi);
    cosphi= cos(phi);
    direction = sign(cosphi);
    
    pixel_in_x = ceil(abs(blur_length*cosphi))+1;
    pixel_in_y = ceil(abs(blur_length*sinphi))+1;
    
    %diagonal_length = norm([pixel_in_x-1,pixel_in_y-1],2);
    offset=(pixel_in_x-1-blur_length*abs(cosphi))/2;
    
    
    %filter = zeros(pixel_in_y,pixel_in_x);
    histo_matrix = zeros(pixel_in_y,pixel_in_x);
    
    x = 0:(blur_length/partition_number):pixel_in_x-1-2*offset;
    y = abs(x*sinphi/cosphi);
    x = x+offset;
    for i=1:length(x)
        if(x(i)-floor(x(i))<0.5)
            pos_x = int16(floor(x(i)))+1;
        else
            pos_x = int16(ceil(x(i)))+1;
        end
        if(y(i)-floor(y(i))<0.5)
            pos_y = int16(floor(y(i)))+1;
        else
            pos_y = int16(ceil(y(i)))+1;
        end
        histo_matrix(pos_y,pos_x) = histo_matrix(pos_y,pos_x)+1;
    end
    
    histo_matrix = histo_matrix/sum(sum(histo_matrix));
    
    if(direction==1)
        histo_matrix = flipud(histo_matrix);
    end
else
    
    histo_matrix = filter_intersection(blur_length,0);
    histo_matrix = histo_matrix';
    return;
end
