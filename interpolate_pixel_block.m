function out = interpolate_pixel_block(in, filter, pos)

%% calculation of interpolated pixels
% filter: hfilter/qfilter 
% pos:    only used by qfilter and show the pixels that would be used by
%         calculation
[height, width] = size(in);

height = height -6;
width  = width  -6;
out = zeros(height, width); 


    if strcmp(pos,'left')||strcmp(pos,'above')
       type = 1;  % for position left or above center, e.g. a,d
    else
        if strcmp(pos,'right')||strcmp(pos,'below')
            type = 2;  % e.g c,n
        else 
            type = 0;     % half-pel b,h
        end
    end

% how to change horizontal and vertical
[row, col] = size(filter);
% fil_range = min(row,col);
if (strcmp(pos,'left')||strcmp(pos,'center')||strcmp(pos,'right'))
    sort = 0;   % line > col, vertical filter
    iteration = width;
    fil_range = col;
else
    sort = 1;   % horizontal filter
    iteration = height;
    fil_range = row;
end

if type == 0    % half pel
    for i=1:iteration-1
        if sort
            tmp = in(i:fil_range+i-1,4:width+3).*filter;
            out(i,:) = sum(tmp,1)./64;
        else
            tmp = in(4:height+3, i:fil_range+i-1).*filter;
            out(:,i) = sum(tmp,2)./64;
        end
    end
else            % quartel pel
    if type == 1 % position like a and d
        for i=1:iteration-1
            if sort
                tmp = in(i:fil_range+i-1,4:width+3).*filter;
                out(i,:) = sum(tmp,1)./64;
            else
                tmp = in(4:height+3, i:fil_range+i-1).*filter;
                out(:,i) = sum(tmp,2)./64;
            end
        end
    else % type == 2 position like n and c
        for i=1:iteration-1
            if sort
                tmp = in(i+1:fil_range+i,4:width+3).*filter;
                out(i,:) = sum(tmp,1)./64;
            else
                tmp = in(4:height+3, i+1:fil_range+i).*filter;
                out(:,i) = sum(tmp,2)./64;
            end
        end
    end
end