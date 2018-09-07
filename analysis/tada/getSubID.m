function [subID subLen]= getSubID (ID)
if strfind(ID, '_')
    subID = {ID(1:strfind(ID, '_')-1) ID(strfind(ID, '_')+1:end)};
    subLen = 2;
else
    subID = {ID};
    subLen = 1;
end