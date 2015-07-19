local shapes = {}

local function static_init()
    local bed_width = bs
    local bed_height = bs * 2

    local base = {
        0, 0,
        bed_width, 0,
        bed_width, bed_height,
        0, bed_height
    }

    local pillow_margin = bs / 7
    local pillow_height = bs / 1.5

    local pillow = {
        pillow_margin, pillow_margin,
        bed_width - pillow_margin, pillow_margin,
        bed_width - pillow_margin, pillow_height,
        pillow_margin, pillow_height
    }

    local sheet_margin = bs / 8

    local sheet = {
        sheet_margin, sheet_margin + bs / 2,
        bed_width - sheet_margin, sheet_margin + bs / 2,
        bed_width - sheet_margin, bed_height - sheet_margin,
        sheet_margin, bed_height - sheet_margin
    }

    shapes = {
        base = pvx_add_shape(0.4, 0.4, 0.4, base),
        pillow = pvx_add_shape(0.9, 0.9, 0.9, pillow),
        sheet = pvx_add_shape(0.86, 0.8, 0.6, sheet)
    }
end

Entity.add_static_init_func(static_init)

BedAct = class(BedAct)

function BedAct:init()
end

function BedAct:calc_bounds(pos)
    return {
        left = pos.x,
        top = pos.y,
        right = pos.x + bs,
        bottom = pos.y + bs * 2
    }
end

function BedAct:get_size()
    return Vector2(bs, bs * 2)
end

function BedAct:draw()
    local x, y = self.entity:get_position():unpack()
    pvx_draw_shape(shapes.base, x, y)
    pvx_draw_shape(shapes.pillow, x, y)
end

function BedAct:get_interact_pos()
    return self.entity:get_position() + self:get_size() * 0.5
end

BedSheetAct = class(BedSheetAct)

function BedSheetAct:init()
end

function BedSheetAct:calc_bounds(pos)
    return {
        left = pos.x,
        top = pos.y,
        right = pos.x + bs,
        bottom = pos.y + bs * 2
    }
end

function BedSheetAct:get_size()
    return Vector2(bs, bs * 2)
end

function BedSheetAct:draw()
    local x, y = self.entity:get_position():unpack()
    pvx_draw_shape(shapes.sheet, x, y)
end

function BedSheetAct:get_sort_key()
    return 10000000000
end
