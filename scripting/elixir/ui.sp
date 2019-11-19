void StartMainMenu(int client){
    Menu menu = new Menu(MenuHandler_StartMainMenu);
    menu.SetTitle("Elixir - %s\n%T\n%T", PLUGIN_VERSION, "Balance", client, _uCoins[client], "Id", client, _uID[client]);

    static char buffer[64];
    FormatEx(buffer, 64, "%T", "Shop", client);
    menu.AddItem("1", buffer);

    if(_info != null){
        FormatEx(buffer, 64, "%T", client, "Information");
        menu.AddItem("2", buffer);
    }

    menu.Display(client, MENU_TIME_FOREVER);
}

void StartShopMenu(client){
    
}

void StartInfoPanel(int client){
    if(_info != null){
        static char buffer[16];
        FormatEx(buffer, 16, "%T", client, "Back");

        if(_info.CurrentKey != 9){
            _info.CurrentKey = 9;
            _info.DrawItem(buffer, ITEMDRAW_CONTROL);
        }

        _info.Send(client, PanelHandler_StartInfoPanel, MENU_TIME_FOREVER);
    }
}

public int MenuHandler_StartMainMenu(Menu menu, MenuAction action, int client, int item){
    switch(action){
        case MenuAction_End: delete menu;
        case MenuAction_Select: {
            char info[4];
            menu.GetItem(item, info, 4);

            switch(info[0]){
                case '1': {
                    StartShopMenu(client);
                }
                case '2': {
                    StartInfoPanel(client);
                }
            }
        }
    }
    return 0;
}

public int PanelHandler_StartInfoPanel(Menu menu, MenuAction action, int client, int item){
	switch (action){
		case MenuAction_Select : {
			if (item == 9) {
				StartMainMenu(client);
			}
		}
	}
}