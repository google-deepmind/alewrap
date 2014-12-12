--[[ Copyright 2014 Google Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
]]

require 'paths'

-- Reads the whole content of the specified file.
local function readContent(path)
    local file = io.open(path)
    local content = file:read("*a")
    file:close()
    return content
end

-- Appends all srcList values to the destList.
local function appendAll(destList, srcList)
    for _, val in ipairs(srcList) do
        table.insert(destList, val)
    end
end


local ffi = require 'ffi'
-- We let the ale::ALEInterface to look like a C struct.
ffi.cdef("typedef struct ALEInterface ALEInterface;")
ffi.cdef(readContent(paths.thisfile("alewrap.inl")))
local lib = ffi.load(package.searchpath('libalewrap',package.cpath))

-- Defining the metatable for ALEInterface userdata.
local mt = {}
mt.__index = mt
mt.act = lib.ale_act
mt.getScreenWidth = lib.ale_getScreenWidth
mt.getScreenHeight = lib.ale_getScreenHeight
mt.fillObs = lib.ale_fillObs
mt.fillRamObs = lib.ale_fillRamObs
mt.isGameOver = lib.ale_isGameOver
mt.resetGame = lib.ale_resetGame
mt.loadState = lib.ale_loadState
mt.saveState = lib.ale_saveState
mt.numActions = lib.ale_numLegalActions
mt.actions = lib.ale_legalActions
mt.lives = lib.ale_livesRemained

mt.restoreSnapshot = function(self, snapshot)
    lib.ale_restoreSnapshot(self, snapshot, #snapshot)
end

mt.saveSnapshot = function(self)
    local size = lib.ale_getSnapshotLength(self)
    local buf = ffi.new("char[?]", size)
    lib.ale_saveSnapshot(self, buf, size)
    return ffi.string(buf, size)
end


ffi.metatype("ALEInterface", mt)

-- Creates a new ALEInterface instance.
function alewrap.newAle(romPath)
    if not paths.filep(romPath) then
        error(string.format('no such ROM file: %q', romPath))
    end
    return ffi.gc(lib.ale_new(romPath), lib.ale_gc)
end

-- Converts the palette values to RGB values.
-- A new ByteTensor is returned.
function alewrap.getRgbFromPalette(obs)
    obs = obs:contiguous()
    assert(obs:nElement() == obs:storage():size(),
        "the obs should not share a bigger storage")
    local rgbShape = {3}
    appendAll(rgbShape, obs:size():totable())

    local rgb = torch.ByteTensor(unpack(rgbShape))
    lib.ale_fillRgbFromPalette(torch.data(rgb), torch.data(obs),
            rgb:nElement(), obs:nElement())
    return rgb
end



