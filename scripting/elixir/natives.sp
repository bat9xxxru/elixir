public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int max){
    CreateNative("Elixir_GetDatabase", Elixir_GetDatabase);

    RegPluginLibrary("elixir");
    return APLRes_Success;
}

public int Elixir_GetDatabase(Handle plugin, int params){
    return view_as<int>(CloneHandle(_database, plugin));
}