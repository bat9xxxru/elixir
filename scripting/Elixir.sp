#pragma tabsize 0

#include <sourcemod>

#if SOURCEMOD_V_MINOR < 9
	#error This plugin can only compile on SourceMod 1.9.
#endif

#define PLUGIN_VERSION "2.0"

Database _database;

Panel _info;

int _countRetryConnect, _afterHowMuch = 86400, _uID[MAXPLAYERS + 1], _uCoins[MAXPLAYERS + 1];

char _uUID[MAXPLAYERS + 1][32], _logPath[PLATFORM_MAX_PATH];

#include "elixir/stocks.sp"
#include "elixir/database.sp"
#include "elixir/ui.sp"
//#include "elixir/parser.sp"
//#include "elixir/natives.sp"

public Plugin myinfo = { 
    name = "Elixir", 
    author = "bat9xxx", 
    version = PLUGIN_VERSION, 
    url = "github.com/bat9xxxru || Rampage#8290"
}

public void OnPluginStart(){
    BuildPath(Path_SM, _logPath, PLATFORM_MAX_PATH, "logs/elixir.log");

    /*char buffer[64];
    ConVar cvar;
    (cvar = CreateConVar("elixir_afterhowmuch", "2592000", "Через сколько дней удалять игрока из БД, который не играет больше, а также, если у него на счету 0 монет.")).AddChangeHook(CVarChanged_AfterHowMuch);
    _afterHowMuch = cvar.IntValue;*/

    RegConsoleCmd("sm_elixir", CommandElixir);

    AutoExecConfig(true, "elixir");

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

    if(_info != null) delete _info;

    static char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/elixir/information.txt");

    File file = OpenFile(buffer, "r");

    if(file != null && FileExists(buffer)){
        if(file.ReadLine(buffer, PLATFORM_MAX_PATH)){
            if(buffer[0]){
                _info = new Panel();
                _info.DrawText(buffer);

                while (!file.EndOfFile() && file.ReadLine(buffer, PLATFORM_MAX_PATH)){
                    if(buffer[0]) _info.DrawText(buffer);
                }

                _info.DrawItem(" ", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
            }
        }
    }

    delete file;dwada
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

public Action CommandElixir(int client, int args){
    StartMainMenu(client);
    return Plugin_Handled;
}