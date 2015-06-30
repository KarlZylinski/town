House = class(House)

house_ascii =
[[ /-||--\ 
/    _  \
| O | | |
|   | | |]]

function House:art()
    return house_ascii
end

function House:size()
    return 9, 5
end

function House:position()
    return self.x, self.y
end

function House:set_position(x, y)
    self.x = x
    self.y = y
end