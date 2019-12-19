    function UI.Event:OnKeyDown(inputs)
        Event:forEach("OnKeyDown",(inputs));
    end

    function UI.Event:OnKeyUp (inputs)
        Event:forEach("OnKeyUp",inputs);
    end

    function UI.Event:OnSignal(signal)
        Event:forEach("OnSignal",signal);
    end

    function UI.Event:OnUpdate(time)
        Event:forEach("OnUpdate",time);
    end




    Frame = New("Frame");
    Frame:show(Event);
    Frame:add(
        New("Plane",1):add(
            New("Plane",2):add(
                New("Button",4,"123")
            ),
            New("Plane",3)
        )
    );

    Component1 = Frame:findById(1);
    Component1.style.top = 20;
    Component1.style.left = 20;
    Component1.style.width = 60;
    Component1.style.height = 30;

    Component2 = Frame:findById(2);
    Component2.style.width = 50;
    Component2.style.height = 20;

    Component3 = Frame:findById(3);
    Component3.style.width = 50;
    Component3.style.height = 20;

    Component3 = Frame:findById(4);
    Component3.style.left = 10;
    Component3.style.top =10;
    Component3.style.width = 80;
    Component3.style.height = 80;
    Component3.style.backgroundcolor.blue = 0;

    Frame:reset();
    Frame:paint();
    Frame:setFocus(Component1);

    Frame:hide();
    Frame:show();


    print("KKK");