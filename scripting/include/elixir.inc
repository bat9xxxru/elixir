#if defined _elixir_included
  #endinput
#endif
#define _elixir_included

/*
* Получаем указатель для работы с базой данных.
*
* @return Handle
*/
native Database Elixir_GetDatabase();



public SharedPlugin __pl_elixir = {
	name = "elixir",
	file = "Elixir.smx",
#if defined REQUIRE_PLUGIN
    required = 1
#else
    required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_elixir_SetNTVOptional(){
	//MarkNativeAsOptional("Elixir_RegisterModule");
}
#endif