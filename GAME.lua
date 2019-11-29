Class = {};
function Class:Create(name,father)
	local object={};
	Class[name]=object;
	setmetatable(object,Class[father] or {});
	object.__index=object;
	function object:constructor()

	end
	return object;
end
function Class:New(name,...)
	local object = {};
	setmetatable(object,Class[name]);
	object.super=getmetatable(object);
	object.__index=object;

	object:constructor(...);
	return object;
end

Component=Class:Create("Component");
function Component:constructor()
	print("我是组件");
end
Component.x=15;

Box=Class:Create("Box","Component");
function Box:constructor()
	print("我是盒子");
end

c1=Class:New("Box");

print(c1.x);





