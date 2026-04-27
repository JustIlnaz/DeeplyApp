using DeeplyApi.Connection;
using DeeplyApi.Requests;
using DeeplyApi.Hubs;
using DeeplyApi.Interfaces;
using DeeplyApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace DeeplyApi.Services;

public class ChatService(AppDbContext db, IHubContext<ChatHub> hub) : IChatService
{
    public async Task<ActionResult> History(int userId, int take)
    {
        var couple = await db.Couples.FirstOrDefaultAsync(x => x.User1Id == userId || x.User2Id == userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });

        var data = await db.ChatMessages
            .Where(x => x.CoupleId == couple.Id)
            .OrderByDescending(x => x.SentAtUtc)
            .Take(Math.Clamp(take, 1, 200))
            .OrderBy(x => x.SentAtUtc)
            .ToListAsync();
        return new OkObjectResult(data);
    }

    public async Task<ActionResult> Send(int userId, CreateChatMessageRequest request)
    {
        var couple = await db.Couples.FirstOrDefaultAsync(x => x.User1Id == userId || x.User2Id == userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        if (string.IsNullOrWhiteSpace(request.Text) && string.IsNullOrWhiteSpace(request.PhotoUrl))
            return new BadRequestObjectResult(new { message = "Message payload required" });

        var message = new ChatMessage
        {
            CoupleId = couple.Id,
            SenderUserId = userId,
            Text = request.Text,
            PhotoUrl = request.PhotoUrl
        };
        db.ChatMessages.Add(message);
        await db.SaveChangesAsync();
        await hub.Clients.Group($"couple:{couple.Id}").SendAsync("message:new", message);
        return new OkObjectResult(message);
    }

    public async Task<ActionResult> MarkRead(int userId, int messageId)
    {
        var couple = await db.Couples.FirstOrDefaultAsync(x => x.User1Id == userId || x.User2Id == userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });

        var message = await db.ChatMessages.FirstOrDefaultAsync(x => x.Id == messageId && x.CoupleId == couple.Id);
        if (message is null) return new NotFoundResult();
        message.IsRead = true;
        await db.SaveChangesAsync();
        await hub.Clients.Group($"couple:{couple.Id}").SendAsync("message:read", new { messageId = message.Id });
        return new OkObjectResult(new { message = "Read status updated" });
    }
}
