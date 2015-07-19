BedAct = class(BedAct)

local shapes = {}

local function static_init()
    local bed_width = bs * 1.5
    local bed_height = bs * 2

    local base = {
        0, 0,
        bed_width, 0,
        bed_width, bed_height,
        0, bed_height
    }

    local sheet_margin = bs / 4

    local sheet = {
        sheet_margin, sheet_margin + bs / 2,
        bed_width - sheet_margin, sheet_margin + bs / 2,
        bed_width - sheet_margin, bed_height - sheet_margin,
        sheet_margin, bed_height - sheet_margin
    }

    shapes = {
        base = pvx_add_shape(0.99, 0.99, 0.9, base),
        sheet = pvx_add_shape(0.86, 0.8, 0.6, sheet)
    }
end

Entity.add_static_init_func(static_init)

function BedAct:init()
end

function BedAct:calc_bounds(pos)
    return {
        left = pos.x,
        top = pos.y,
        right = pos.x + bs * 1.5,
        bottom = pos.y + bs * 2
    }
end

function BedAct:get_size()
    return Vector2(bs * 1.5, bs * 2)
end

function BedAct:draw()
    local x, y = self.entity:get_position():unpack()
    pvx_draw_shape(shapes.base, x, y)
    pvx_draw_shape(shapes.sheet, x, y)
end

function BedAct:get_interact_pos()
    return self.entity:get_position() + self:get_size() * 0.5
end
