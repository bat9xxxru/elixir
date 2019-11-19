#include <sourcemod>


void ConnectDatabase(){
    char id[16], error[256], query[512];
    bool sqlite;

    if(SQL_CheckConfig("elixir")) _database = SQL_Connect("elixir", false, error, 256);
    else _database = SQLite_UseDatabase("elixir", error, 256);

    if(!_database) SetFailState("Failed to connect to database (%s)", error);

    _database.Driver.GetIdentifier(id, 16);
    if(id[0] == 's') sqlite = true; 

    SQL_LockDatabase(_database);

    _database.Format(query, 512, "CREATE TABLE IF NOT EXISTS `users` ( \
                                 `id` INTEGER PRIMARY KEY %s,
                                 `uid` varchar(32) NOT NULL UNIQUE, \
                                 `coins` INTEGER NOT NULL default 0, \
                                 `lastvisit` INTEGER NOT NULL default 0)%s", sqlite ? "AUTOINCREMENT" : "AUTO_INCREMENT", sqlite ? ";" : " CHARSET=utf8 COLLATE utf8_general_ci");
    if(!SQL_FastQuery(_database, query)) SetFailState("Failed to create tables");
    SQL_UnlockDatabase(_database);

    _database.SetCharset("utf8");
}

void ReconnectDatabase(){
	delete _database;
	_countRetryConnect = 0;
	CreateTimer(3.0, ReconnectTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

void LoadDataPlayer(int client){
	if(!_database){
		LogError("Database not available");
		return;
	}

    GetClientAuthId(client, AuthId_Steam2, _uUID[client], 32);

    char query[128];
    _database.Format(query, 128, "SELECT `id`, `coins` FROM `users` WHERE `uid` = '%s' AND `lastvisit` > '%i'", _uUID[client], GetTime());
    _database.Query(LoadDataPlayerCallBack, query, client);
}

void SaveDataPlayer(int client){
	if(!_database){
		LogError("Database not available");
		return;
	}

    char query[128];
    _database.Format(query, 128, "UPDATE `users` SET `coins` = '%i' `lastvisit` = '%i', WHERE `id` = '%i'", _uCoins[client], GetTime() + _afterHowMuch, _uID[client]);
    _database.Query(Stub, query, _, DBPrio_High);

    _uID[client] = 0;
    _uCoins[client] = 0;
}

void CreateAccount(int client){
	if(!_database){
		LogError("Database not available");
		return;
	}

    char query[128];
    _database.Format(query, 128, "INSERT INTO `users` (`uid`) VALUES (`%s`)", _uUID[client]);
    _database.Query(CreateAccountCallBack, query, client);
}

void AutoCleaning(){
	if(!_database){
		LogError("Database not available");
		return;
	}

    char query[128];
    _database.Format(query, 128, "DELETE FROM `users` WHERE `lastvisit` < '%i'", GetTime());
    _database.Query(Stub, query);
}

public Action ReconnectTimer(Handle hTimer){
	char error[256];
	_database = SQL_Connect("elixir", false, error, 256);

	if(!_database){
		_countRetryConnect++;
		if(_countRetryConnect >= 5) SetFailState("Attempt to reconnect failed - (%s)", error);
	}
	else{
		_database.SetCharset("utf8");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void Stub(Database db, DBResultSet result, const char[] error, any data){
	if(!result){
		LogError("%s", error);
		if(StrContains(error, "Lost connection to MySQL", false) != -1){
			ReconnectDatabase();
		}
	}
}

public void LoadDataPlayerCallBack(Database db, DBResultSet result, const char[] error, any data){
	if(!result){
		LogError("%s", error);
		if(StrContains(error, "Lost connection to MySQL", false) != -1){
			ReconnectDatabase();
		}
        return;
	}

    if(!IsClientInGame(client)) return;

    if(result.HasResults && result.FetchRow()){
        _uID[client] = result.FetchInt(0);
        _uCoins[client] = result.FetchInt(1);
        CreateTimer(3.0, Welcome, client);
    }
    else{
        CreateAccount(client);
    }
}

public void CreateAccountCallBack(Database db, DBResultSet result, const char[] error, any data){
	if(!result){
		LogError("%s", error);
		if(StrContains(error, "Lost connection to MySQL", false) != -1){
			ReconnectDatabase();
		}
        return;
	}

    if(IsClientInGame(client) && result.InsertId) {
		_uID[client] = result.InsertId;
		CreateTimer(3.0, Welcome, client);
	}
}