#include <sourcemod>
#include <tf2_stocks>

#define UPDATE_URL ""
#define PLUGIN_VERSION "1.0"
#define PLUGIN_NAME "Force Picker"
#define PLUGIN_AUTHOR "Statik"

new minPlayers = 2;

public Plugin:myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Tool to make the pick up games quicker",
	version = PLUGIN_VERSION,
	url = ""
}

/*==================================
*******ONFUNCTIONS & EVENTS*********
==================================*/

public OnPluginStart()
{
	// Commands
	RegConsoleCmd("forcepicker", cmdForcePickers, "Forces random people from spec to pick players");
	
	// Quick Commands
	AddCommandListener(cmdSay, "say");
	AddCommandListener(cmdSay, "say_team");
}

/*==================================
*********CLIENT COMMANDS************
==================================*/

public Action:cmdForcePickers(client, args)
{
	cmdExecutor(client);
	return Plugin_Continue;
}

public Action:cmdSay(client, const String:command[], args)
{
	new String:text[192];
	GetCmdArgString(text, sizeof(text));
	
	new startidx = 0;
	if (text[0] == '"')
	{
		startidx = 1;
		new len = strlen(text);
		if (text[len-1] == '"')
		{
			text[len-1] = '\0';
		}
	}
	
	if (StrEqual(text[startidx], ".fp", false))
	{
		CreateTimer(0.1, tmrAuxExecutor, client);
	}
	
	return Plugin_Continue;
}

public Action:tmrAuxExecutor(Handle:timer, any:client) 
{ 
	if (IsClientInGame(client)) { cmdExecutor(client); }
}

cmdExecutor(client)
{
	if (!GetAdminFlag(GetUserAdmin(client), Admin_Generic)) // Checks if client is not a generic admin
	{
		PrintToChat(client, "\x07DD37F6FP | \x01You do not have access to this command.");
		return;
	}
	if (GetRealClientCount() < minPlayers)
	{
		PrintToChat(client, "\x07DD37F6FP | \x01There is no enough players to pick.");
		return;
	}
	if ((GetTeamClientCount(2) != 0) && (GetTeamClientCount(3) != 0)) // Checks if there are players in both teams already
	{
		PrintToChat(client, "\x07DD37F6FP | \x01There are already players in both teams.");
		return;
	}
	
	ForcePickers();
}

/*==================================
*************MAIN CODE**************
==================================*/

ForcePickers()
{
	
	new redCount = GetTeamClientCount(2);
	new bluCount = GetTeamClientCount(3);
	
	/*
	if ((redCount + bluCount) > 1)
	{ // If there's too much people playing they are moved to spec
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i)) 
				ChangeClientTeam(i, 1);
		}
		redCount = 0;
		bluCount = 0;
	}
	*/
	
	new client1, client2;
	if (redCount == 0)
	{
		do client1 = GetRandomInt(1,MaxClients);
		while (!IsClientInGame(client1) || (GetClientTeam(client1) != 1));
		ChangeClientTeam(client1, 2); // Red
	}
	else 
	{	// Get current player in the team
		do client1 = GetRandomInt(1,MaxClients);
		while (!(IsClientInGame(client1) && (GetClientTeam(client1) == 2)));
	}
	
	if (bluCount == 0)
	{
		do client2 = GetRandomInt(1,MaxClients);
		while (!IsClientInGame(client2) || (GetClientTeam(client2) != 1));
		ChangeClientTeam(client2, 3); // Blu
	}
	else 
	{	// Get current player in the team
		do client2 = GetRandomInt(1,MaxClients);
		while (!(IsClientInGame(client2) && (GetClientTeam(client2) == 3)));
	}
	
	TF2_SetPlayerClass(client1, TFClass_Scout);
	TF2_SetPlayerClass(client2, TFClass_Scout);
	
	TF2_RespawnPlayer(client1);
	TF2_RespawnPlayer(client2);

	CreateTimer(0.1, tmrMeleeStrip, client1);
	CreateTimer(0.1, tmrMeleeStrip, client2);
	
	if (redCount == 0 && bluCount == 0)
		PrintToChatAll("\x07DD37F6FP | \x07FF4040%N \x01and \x0799CCFF%N \x01have been randomly chosen to pick.", client1, client2);
	else if (redCount == 0)
		PrintToChatAll("\x07DD37F6FP | \x07FF4040%N \x01has been randomly chosen to pick against \x0799CCFF%N\x01.", client1, client2);
	else if (bluCount == 0)
		PrintToChatAll("\x07DD37F6FP | \x0799CCFF%N \x01has been randomly chosen to pick against \x07FF4040%N\x01.", client2, client1);
}

// Change to weapon slot 2 (Melee)
public Action:tmrMeleeStrip(Handle:timer, any:client) 
{ 
	if (client && IsPlayerAlive(client))
	{
		new weapon = GetPlayerWeaponSlot(client, 2);
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	}
}

/*==================================
*********EXTRA FUNCTIONS************
==================================*/

GetRealClientCount(bool:inGameOnly = true) 
{
	new clients = 0;
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if(((inGameOnly) ? IsClientInGame(i) : IsClientConnected(i)) /*&& !IsFakeClient(i)*/) 
			clients++;
	}
	return clients;
}