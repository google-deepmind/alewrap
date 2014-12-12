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

local alewrap = require 'alewrap'


local function parseArgs()
    local cmd = torch.CmdLine()
    cmd:option('-rom', 'roms/pong.bin', 'ROM to use')
    cmd:option('-action', 0, 'action to use')
    cmd:option('-output', 'frames.dat', 'output path')
    cmd:option('-skip', 0, 'number of initial frames to skip')
    cmd:option('-diffScreen', false, 'compare the screens instead of RAM')

    return cmd:parse(arg)
end

local MAX_PERIOD = 2^15 + 1

local diff = torch.ByteTensor()
local function isEq(a, b)
    diff:resizeAs(a):copy(a):add(-1, b)
    diff:cmul(diff)
    return diff:max() == 0
end

local function isScreenEq(aObservations, bObservations)
    return isEq(aObservations[1], bObservations[1])
end

local function isRamEq(aObservations, bObservations)
    return isEq(aObservations[2], bObservations[2])
end

-- Returns a tensor with frames.
-- The recording is stopped, when the RAM starts repeating.
local function recordFrames(options)
    local actions = {torch.Tensor({options.action})}
    local env = alewrap.createEnv(options.rom, {enableRamObs=true})
    local firstObservations = env:envStart()
    for i = 1, options.skip do
        local reward
        reward, firstObservations = env:envStep(actions)
    end

    local isObsEq = isRamEq
    if options.diffScreen then
        isObsEq = isScreenEq
    end

    local firstObs = firstObservations[1]
    local observations = firstObservations
    local frames = torch.ByteTensor(MAX_PERIOD, firstObs:size(1), firstObs:size(2))
    for step = 1, MAX_PERIOD do
        local obs = observations[1]
        frames[step]:copy(obs)

        local reward
        reward, observations = env:envStep(actions)

        if isObsEq(firstObservations, observations) then
            return frames[{{1, step}}]:clone()
        end
    end

    error(string.format("no period found in the first %s steps", MAX_PERIOD))
end


local function main()
    local options = parseArgs()
    local frames = recordFrames(options)
    print("period length:", frames:size(1))
    torch.save(options.output, frames)
end

main()
