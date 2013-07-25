function [t] = statxture(f, scale)
%see pg 605 Gonzalez, Woods

if nargin == 1 
    scale(1:6) = 1;
else
    scale = scale(:)';
end

p=imhist(f);
p=p./numel(f);
L=length(p);

[~,mu]=statmoments(p,3);

%average gray level
t(1)=mu(1);
%standard deviation
t(2)=mu(2).^0.5;
%smoothness
varn=mu(2)/(L-1)^2;
t(3) = 1 - 1/(1+varn);
%third moment
t(4)=mu(3)/(L-1)^2;
%uniformity
t(5)=sum(p.^2);
%entropy
t(6) = -sum(p.*(log2(p+eps)));

t=t.*scale;
