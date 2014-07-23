function [ B] = plusminus90( B )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
            if abs(B) > 90
                choices = [B-180,B+180];
                [~,index] = min([abs(B-180),abs(B+180)]);
                B = choices(index);
            end

end

