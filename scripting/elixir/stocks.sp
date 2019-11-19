stock void PrintToChat2(int iClient, char[] szMessage, any ...){
	static int			iEngine = -1;
	static const int	g_iColorsCSSOB[] = {0xFFFFFF, 0xFF0000, 0x00AD00, 0x00FF00, 0x99FF99, 0xFF4040, 0xCCCCCC, 0xFFBD6B, 0xFA8B00, 0x99CCFF, 0x3D46FF, 0xFA00FA};
	static const char	g_sColorsOldBefore[][] = {"{DEFAULT}", "{TEAM}", "{GREEN}"},
					g_sColorsOldCSS[][] = {"\x01", "\x03", "\x04"},
					g_sColorsBefore[][] = {"{WHITE}", "{RED}", "{GREEN}", "{LIME}", "{LIGHTGREEN}", "{LIGHTRED}", "{GRAY}", "{LIGHTOLIVE}", "{OLIVE}", "{LIGHTBLUE}", "{BLUE}", "{PURPLE}"},
					g_sColorsCSGO[][] = {"\x01", "\x02", "\x04", "\x05", "\x06", "\x07", "\x08", "\x09", "\x10", "\x0B", "\x0C", "\x0E"};


	if(iClient && IsClientInGame(iClient) && !IsFakeClient(iClient))
	{
		char szBuffer[PLATFORM_MAX_PATH], szNewMessage[PLATFORM_MAX_PATH];

		if(iEngine == -1)
		{
			switch(GetEngineVersion())
			{
				case Engine_CSGO: iEngine = 0;
				case Engine_CSS: iEngine = 1;
				case Engine_SourceSDK2006: iEngine = 2;
			}
		}

		Format(szBuffer, sizeof(szBuffer), !iEngine ? " \x01%s" : "\x01%s", szMessage);
		VFormat(szNewMessage, sizeof(szNewMessage), szBuffer, 3);

		if(!iEngine)
		{
			for(int i = 0; i < 12; i++)
			{
				ReplaceString(szNewMessage, sizeof(szNewMessage), g_sColorsBefore[i], g_sColorsCSGO[i]);
			}
			ReplaceString(szNewMessage, sizeof(szNewMessage), "{TEAM}", "\x03");
		}
		else
		{
			if(iEngine == 1)
			{
				char sBuff[64];
				switch(GetClientTeam(iClient))
				{
					case 1: Format(sBuff, sizeof(sBuff), "\x07%06X", g_iColorsCSSOB[6]);
					case 2: Format(sBuff, sizeof(sBuff), "\x07%06X", g_iColorsCSSOB[5]);
					case 3: Format(sBuff, sizeof(sBuff), "\x07%06X", g_iColorsCSSOB[9]);
				}
				ReplaceString(szNewMessage, sizeof(szNewMessage), "{TEAM}", sBuff);

				for(int i = 0; i < 12; i++)
				{
					Format(sBuff, sizeof(sBuff), "\x07%06X", g_iColorsCSSOB[i]);
					ReplaceString(szNewMessage, sizeof(szNewMessage), g_sColorsBefore[i], sBuff);
				}
			}
			else
			{
				for(int i = 0; i < 3; i++)
				{
					ReplaceString(szNewMessage, sizeof(szNewMessage), g_sColorsOldBefore[i], g_sColorsOldCSS[i]);
				}
			}
		}

		Handle hBf = StartMessageOne("SayText2", iClient, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
		if(hBf)
		{
			if(GetUserMessageType() == UM_Protobuf)
			{
				Protobuf hProtoBuffer = UserMessageToProtobuf(hBf);
				hProtoBuffer.SetInt("ent_idx", iClient);
				hProtoBuffer.SetBool("chat", true);
				hProtoBuffer.SetString("msg_name", szNewMessage);
				hProtoBuffer.AddString("params", "");
				hProtoBuffer.AddString("params", "");
				hProtoBuffer.AddString("params", "");
				hProtoBuffer.AddString("params", "");
			}
			else
			{
				BfWrite hBfBuffer = UserMessageToBfWrite(hBf);
				hBfBuffer.WriteByte(iClient);
				hBfBuffer.WriteByte(true);
				hBfBuffer.WriteString(szNewMessage);
			}
		}
		EndMessage();
	}
}