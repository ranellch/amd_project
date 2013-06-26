function [name] = parse_outname(thestring)
    %Get the last index of the dot
    dotend = strfind(thestring, '.');
    lengthdot = length(dotend);
    dotindex = 0;
    if lengthdot > 0
        dotindex = dotend(lengthdot) - 1;
    end

    %Get the last index of the slash
    slashstart = strfind(thestring, '/');
    lengthlash = length(slashstart);
    slashindex = 0;
	if lengthlash > 0
        slashindex = slashstart(lengthlash) + 1;
    else
        slashindex = 1;
    end

    if slashindex > 0 && dotindex > 0
        name = thestring(slashindex:dotindex);
    else
        name = 'parse_error';
    end
end
