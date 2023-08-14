#include <sourcemod>
#include <ripext>

#pragma semicolon 1
#pragma newdecls required

#define GEOIP_API_TOKEN "@YOUR_PRIVATE_TOKEN"

public Plugin myinfo =
{
    name = "Connect Announce",
    author = "Nixtap",
    description = "Displays the joining player's name and country",
    version = "1.0",
    url = "https://github.com/nixtap/ConnectAnnounce"
};

ConVar g_Cvar_IsEnabled;
ConVar g_Cvar_RequestTimeout;

public void OnPluginStart()
{
    g_Cvar_IsEnabled = CreateConVar("connect_announce_enabled", "1");
    g_Cvar_RequestTimeout = CreateConVar("connect_announce_timeout", "10");

    AutoExecConfig(true, "connect_announce");
}

public void OnClientPostAdminCheck(int client)
{
    if (client == 0 || IsFakeClient(client))
    {
        return;
    }
    if (g_Cvar_IsEnabled.BoolValue)
    {
        Geolocation(client);
    }
}

static void Geolocation(int client)
{
    if (client == 0 || IsFakeClient(client))
    {
        return;
    }
    char ip[48];
    GetClientIP(client, ip, sizeof(ip));

    if (strlen(ip) > 0 && strlen(ip) <= 15)
    {
        HTTPRequest request = new HTTPRequest("https://api.ip138.com/ip/");
        request.ConnectTimeout = g_Cvar_RequestTimeout.IntValue;
        request.AppendQueryParam("ip", ip);
        request.AppendQueryParam("token", GEOIP_API_TOKEN);
        request.Get(OnGeolocationRequestFinished, GetClientUserId(client));
    }
}

static void OnGeolocationRequestFinished(HTTPResponse response, int userId)
{
    char errorMessage[32];
    JSONObject restResult = view_as<JSONObject>(response.Data);
    if (response.Status != HTTPStatus_OK)
    {
        if (restResult.GetString("msg", errorMessage, sizeof(errorMessage)))
        {
            LogError("Connect Announce: %s", errorMessage);
        }
        LogError("Connect Announce: HTTP error code %d", response.Status);
        return;
    }
    int client = GetClientOfUserId(userId);
    if (!IsClientConnected(client))
    {
        return;
    }
    char location[128] = "";
    JSONArray data = view_as<JSONArray>(restResult.Get("data"));
    for (int i = 0; i < 3 && i < data.Length; ++i)
    {
        char buffer[32];
        data.GetString(i, buffer, sizeof(buffer));

        if (strlen(buffer) > 0)
        {
            StrCat(buffer, sizeof(buffer), " ");
            StrCat(location, sizeof(location), buffer);
        }
    }
    delete data;

    char name[32];
    GetClientName(client, name, sizeof(name));
    PrintToChatAll("\x04★\x01欢迎\x03%s\x01来自\x05%s", name, location);
}
