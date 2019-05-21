-- temp node for parsing xml str
local _M = {}
local _NodeInfo = {
	new = function(self)
		local o = {};
		o.name = {1, 1};
		o.loc  = {1, 1};
		o.attr = {1, 1};
		self.__index = self;
		setmetatable(o, self);
		return o;
	end
};

--======================= Xml Tree =========================
_M.XmlTree = {
	new = function(self)
		local o = {};
		o.value = "";
		o.attr  = {};
		o._tmpstr = "";
		o._offset = 0;
		o._eof    = false;
		self.__index = self;
		setmetatable(o, self);
		return o;
	end,

	parse = function(self, xmlstr)
		self._offset = 0;
		self._tmpstr = xmlstr;
		-- skip header
		if not self:_skipHeader() then
			return false;
		end
		self:_parseNode();
	end,

	toString = function(self)
		local s = {'<?xml version="1.0" encoding="UTF-8" ?>'};
		self:_toString(s, 1);
		return table.concat(s, '');
	end,


	_toString = function(self, s, layer)
		for ak, av in pairs(self.attr) do
			s[table.getn(s) + 1] = ' ' .. ak .. '=' .. '"' .. av .. '"';
		end
		if layer > 1 then
			s[table.getn(s) + 1] = '>';
		end
		for k, v in pairs(self)
		do
			if k == 'value' then
				if v and v ~= '' then
					s[table.getn(s) + 1] = v;
				end
			elseif k ~= '_eof' and k ~= '_tmpstr'
				and k ~= '_offset' and k ~= 'attr' then
				s[table.getn(s) + 1] = '<' .. k;
				v:_toString(s, layer + 1)
				s[table.getn(s) + 1] = '</' .. k .. '>';
			end
		end
	end,

	_skipHeader = function(self)
		if self._tmpstr == "" then
			return false;
		end
		local idx = string.find(self._tmpstr, '?>');
		self._offset = idx + 2;
		return true;
	end,

	_getNode = function(self)
		-- get node line
		local x, si = string.find(self._tmpstr, "<", self._offset);
		local ei, x = string.find(self._tmpstr, ">", self._offset);
		if not si or not ei then
			return nil;
		end
		self._offset = x + 1;
		local ni = _NodeInfo:new();
		ni.name[1] = si + 1;
		local x, y = string.find(self._tmpstr, " ", si);
		if not x or x >= ei then
			ni.name[2] = ei - 1;
			ni.attr = nil;
		else
			ni.name[2] = x - 1;
			ni.attr[1] = y + 1;
			ni.attr[2] = ei - 1;
		end
		ni.loc[1] = ei + 1;

		-- get node end
		local nodeName = string.sub(self._tmpstr, ni.name[1], ni.name[2]);
		x, y = string.find(self._tmpstr, '</' .. nodeName .. '>', ei);
		if not x then
			local slash = string.sub(self._tmpstr, ei - 1, ei - 1);
			if slash == '/' then
				x, y = ei - 1, ei;
			else
				return nil;
			end
		end
		ni.loc[2] = x - 1;
		self._offset = y + 1;
		return ni;
	end,

	_parseNode = function(self)
		local ni = self:_getNode();
		if not ni then
			self._eof = true;
			return;
		end
		local n = string.sub(self._tmpstr, ni.name[1], ni.name[2]);
		local node = _M.XmlTree:new();
		self[n] = node;
		node._tmpstr = string.sub(self._tmpstr, ni.loc[1], ni.loc[2]);
		if ni.attr then
			self:_parseAttr(node, ni.attr);
		end;

		-- parse value
		local x, y = string.find(node._tmpstr, '<');
		-- local z, w = string.find(node._tmpstr, '/>');
		-- if x and z then
		if x then
			node:_parseNode();
		else
			node.value = node._tmpstr;
			node._tmpstr = "";
		end

		-- parse next node
		while not self._eof do
			self:_parseNode();
		end
		self._tmpstr = "";
	end,

	_parseAttr = function(self, node, loc)
		local x = loc[1];
		while true do
			if x >=loc[2] then
				break;
			end
			-- TODO: skip space
			local xx, xy = string.find(self._tmpstr, ' ', x);
			if not xx or xx >= loc[2] then
				xx, xy = string.find(self._tmpstr, '/', x);
				if not xx or xx >= loc[2] then
					xx, xy = string.find(self._tmpstr, '>', x);
					if not xx then
						break; -- parse error
					end
					if xx >= loc[2] then
						xx = loc[2] + 1;
					end
				end
				-- xx = x;
			end
			local kx, ky = string.find(self._tmpstr, '=', x);
			if kx then
				local k = string.sub(self._tmpstr, x, kx - 1);
				-- 约定所有的value都必须含引号，所有的value中都不包含空格
				node.attr[k] = string.sub(self._tmpstr, ky + 2, xx - 2);
			end
			x = xy + 1;
		end;
	end
};
return _M;
