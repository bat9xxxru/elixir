#pragma tabsize 0

#include <sourcemod>

#if SOURCEMOD_V_MINOR < 9
	#error This plugin can only compile on SourceMod 1.9.
#endif

Database _database;

int _countRetryConnect, _afterHowMuch = 86400, _uID[MAXPLAYERS + 1], _uCoins[MAXPLAYERS + 1];

char _uUID[MAXPLAYERS + 1][32];

#include "elixir/stocks.sp"
#include "elixir/database.sp"
//#include "elixir/ui.sp"
//#include "elixir/parser.sp"
//#include "elixir/natives.sp"

public Plugin myinfo = { 
    name = "Elixir", 
    author = "bat9xxx", 
    version = "2.0", 
    url = "github.com/bat9xxxru || Rampage#8290"
}

public void OnPluginStart(){

    LoadTranslations(GetEngineVersion() == Engine_SourceSDK2006 ? "elixir_old.phrases" : "elixir.phrases");
    ConnectDatabase();
}

public void OnPluginEnd(){
    for(int i = 1; i <= MaxClients; i++){
        if(IsClientInGame(i)) OnClientDisconnect(i);
    }
}

public void OnMapStart(){
    AutoCleaning();
}

public void OnClientPostAdminCheck(int client){
    if(!IsFakeClient(client)) LoadDataPlayer(client);
}

public void OnClientDisconnect(int client){
    SaveDataPlayer(client);
}

public Action Welcome(Handle timer, int client){
    if(IsClientInGame(client)) PrintToChat2(client, "%t%T", "Prefix", "Welcome", client, _uCoins[client]);
    return Plugin_Stop;
}