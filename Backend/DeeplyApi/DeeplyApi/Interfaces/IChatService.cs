using DeeplyApi.Requests;
using Microsoft.AspNetCore.Mvc;

namespace DeeplyApi.Interfaces;

public interface IChatService
{
    Task<ActionResult> History(int userId, int take);
    Task<ActionResult> Send(int userId, CreateChatMessageRequest request);
    Task<ActionResult> MarkRead(int userId, int messageId);
}
