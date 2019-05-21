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
