if UI then
    local windows = IKit.New("Windows"):add(
        IKit.New("TextView",{"text","我的天啊，这倒是不敢相信，事情怎么会这样!",
        "style.left","5%","style.top","15%","style.width","35%","style.height","35%",
        "style.singleline",true),
        IKit.New("Div",{"style.left","5%","style.top","5%","style.width","35%","style.height","35%"}):add(
            IKit.New("Component",{"style.left","5%","style.top","15%","style.width","35%","style.height","35%"})
        )
    );
    windows:enable();
end