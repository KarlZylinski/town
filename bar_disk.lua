BarDiskAct = class(BarDiskAct)

local shapes = {}
local len = 8

local function static_init()
    local disk_depth = bs/1.5
    local bar = {
        0, 0,
        bs*len, 0,
        bs*len, disk_depth,
        0, disk_depth
    }

    local bar_front = {
        0, disk_depth,
        bs*len, disk_depth,
        bs*len, disk_depth+ bs,
        0, disk_depth + bs
    }

    local gw = 8
    local gh = 12
    local ht = 8
    local hb = 4
    local hw = 2

    local grog = {
        0, 0,
        gw, 0,
        gw, ht,
        gw + hw, ht,
        gw + hw, hb,
        gw, hb,
        gw, gh,
        0, gh
    }

    shapes = {
        bar = pvx_add_shape(0.37, 0.3, 0.15, bar),
        bar_front = pvx_add_shape(0.47, 0.4, 0.25, bar_front),
        grog = pvx_add_shape(0.9, 0.8, 0.05, grog)
    }
end

Entity.add_static_init_func(static_init)

function BarDiskAct:init()
    self.beers = {}

    local function rand_pos()
        return Vector2(math.random(10, 240), math.random(-3, 8))
    end

    for i=1,6 do
        table.insert(self.beers, rand_pos())
    end
end

function BarDiskAct:calc_bounds(pos)
    return {
        left = pos.x,
        top = pos.y,
        right = pos.x + bs*len,
        bottom = pos.y + bs/1.5 + bs
    }
end

function BarDiskAct:get_size()
    return Vector2(bs*len, bs/1.5 + bs)
end

function BarDiskAct:draw()
    local x, y = self.entity:get_position():unpack()
    pvx_draw_shape(shapes.bar, x, y)
    pvx_draw_shape(shapes.bar_front, x, y)

    for _, p in ipairs(self.beers) do
        pvx_draw_shape(shapes.grog, x + p.x, y + p.y)
    end
end

function BarDiskAct:get_interact_pos()
    local pa = self:get_party_area()
    return Vector2(math.random(pa.left, pa.right), math.random(pa.top, pa.bottom))
end

function BarDiskAct:get_party_area()
    local b = self.entity:get_bounds()

    return {
        top = b.top + bs * 2,
        left = b.left,
        right = b.left + len * bs,
        bottom = b.top + bs * 6
    }
end

function BarDiskAct:is_blocking(pos)
    local entity_bounds = self.entity:get_bounds()
    return bounds_contains(entity_bounds, pos)
end