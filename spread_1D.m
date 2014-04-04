function generated_data=spread_1D(X, model)
%close all;
%clc;
% gener = spread_1D(magnitude_1st,model)
[m n]=size(model.mu);

generated_data = 0;
for i=1:n
    x=model.mu(i)+sqrt(model.Sigma(i))*randn(1,length(X)*model.weight(i));
    
    %a=length(x)
    generated_data(end+1:(end+length(x)))=x;
    
end
generated_data = generated_data(2:end);
generated_data = generated_data(generated_data>0);
generated_data = generated_data(generated_data<400);
figure;
hist(generated_data,100);
figure;
hist(X,100);

