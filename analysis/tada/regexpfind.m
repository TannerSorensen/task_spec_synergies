function id = regexpfind (str, expr)

id = [];
if ~isempty(str)
    if iscell(str)
        if ~isempty(str{1})
            x = regexpi(str, expr);

            if iscell(str)
                for i=1:length(x)
                    if ~isempty(x{i})
                        id = [id i];
                    end
                end

            else
                id=x;
            end
        end
    else
        x = regexpi(str, expr);

        if iscell(str)
            for i=1:length(x)
                if ~isempty(x{i})
                    id = [id i];
                end
            end

        else
            id=x;
        end
    end
else
end

if isempty(id)
    id = 0;
end