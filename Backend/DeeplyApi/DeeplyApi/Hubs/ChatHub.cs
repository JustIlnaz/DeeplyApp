using Microsoft.AspNetCore.SignalR;

namespace DeeplyApi.Hubs;

public class ChatHub : Hub
{
    public async Task JoinCoupleRoom(string coupleId) => await Groups.AddToGroupAsync(Context.ConnectionId, $"couple:{coupleId}");
    public async Task LeaveCoupleRoom(string coupleId) => await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"couple:{coupleId}");
}
