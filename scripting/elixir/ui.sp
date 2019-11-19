void StartMainMenu(int client){
    Menu menu = new Menu(MenuHandler_StartMainMenu);
    menu.SetTitle("Elixir - %s\n%T\n%T", PLUGIN_VERSION, "Balance", client, _uCoins[client], "Id", client, _uID[client]);

    char buffer[64];
    FormatEx(buffer, 64, "%T", "Shop", client);
    menu.AddItem("1", buffer);

    /*if(_info != null){
        FormatEx(buffer, 64, "%T", client, "Information");
        menu.AddItem("2", buffer);
    }*/

    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_StartMainMenu(Menu menu, MenuAction action, int client, int item){
    switch(action){
        case MenuAction_End: delete menu;
        case MenuAction_Select: {
            /*char info[4];
            menu.GetItem(item, info, 4);

            switch(info[0]){
                case '1': {
                    StartShopMenu(client);
                }
                case '2': {
                    StartInfoPanel(client);
                }
            }*/
        }
    }
    return 0;
}