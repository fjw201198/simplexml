# simplexml
simplexml library for lua, use luajit rather then lua.

# methods

- XmlTree:new()
- XmlTree:parse(xmlstr)
- XmlTree:toString()

1. XmlTree:new()
create a XmlTree instance.
```lua
local xml = require("simplexml")
local x = xml.XmlTree:new()
```

2. XmlTree:parse(xmlstr)
parse a xml string to the XmlTree object which created by call XmlTree:new()

3. XmlTree:toString()
used to encode the xml instance to xml string

4. Add a node named A to the xml tree named B?  
the node A also a XmlTree
just do this:
```lua
B.A = A;
```

# attributes
- XmlTree.attr
- XmlTree.value

XmlTree.attr is a dictionary, the key is the attributes name.

XmlTree.value stored the value of current node. if the value is a XmlTree, current XmlTree.value is empty and current XmlTree
will has a key named by the sub tree's node.

# Sample

```lua
local xml = require "simplexml"

function XmlObjToStr()
    local testTree = xml.XmlTree:new()
    testTree.Request = xml.XmlTree:new();
    testTree.Request.Hello = xml.XmlTree:new();
    testTree.Request.World = xml.XmlTree:new();
    testTree.Request.Hello.value = "hello";
    testTree.Request.World.value = "world";
    testTree.Request.World.attr = {attr1 = "attr1", attr2 = "attr2"};
    print(testTree:toString());
end

function StrToXmlObj()
    local xmlstr = [[<?xml version="1.0" encoding="UTF-8" ?>
<Request>
  <Hello>hello</Hello>
  <World a="b" c="d" d="e">world</World>
</Request>]]
    local xmlObj = xml.XmlTree:new();
    print(xmlstr);
    xmlObj:parse(xmlstr)
    print(xmlObj.Request.Hello.value);
    print(xmlObj.Request.World.value);
    print(xmlObj.Request.World.attr.a);
    print(xmlObj.Request.World.attr.c);
    print(xmlObj.Request.World.attr.d);
end

XmlObjToStr();
StrToXmlObj();
```
