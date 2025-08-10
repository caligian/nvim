require 'lua-utils.utils'

local M = {
  inspect = require 'lua-utils.inspect',
	string = require 'lua-utils.string',
	list = require 'lua-utils.list',
	dict = require 'lua-utils.dict',
	class = require 'lua-utils.class',
	tuple = require 'lua-utils.tuple',
	types = require 'lua-utils.types',
	copy = require 'lua-utils.copy',
	validate = require 'lua-utils.validate'
}

function M:import()
  inspect = require 'lua-utils.inspect'
  strings = require 'lua-utils.string'
  list = require 'lua-utils.list'
  dict = require 'lua-utils.dict'
  class = require 'lua-utils.class'
  tuple = require 'lua-utils.tuple'
  types = require 'lua-utils.types'
  copy = require 'lua-utils.copy'
  validate = require 'lua-utils.validate'
end

return M
