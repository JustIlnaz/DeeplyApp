using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace DeeplyApi.Controllers;

[Route("api/chat")]
public class ChatController(IChatService service) : ControllerBase
{
    [HttpGet("history")]
    public Task<ActionResult> History([FromQuery] int take = 50)
    {
        if (!TryResolveUserId(out var userId))
            return Task.FromResult<ActionResult>(Unauthorized(new { message = "Unauthorized" }));
        return service.History(userId, take);
    }

    [HttpPost("send")]
    public Task<ActionResult> Send([FromBody] CreateChatMessageRequest request)
    {
        if (!TryResolveUserId(out var userId))
            return Task.FromResult<ActionResult>(Unauthorized(new { message = "Unauthorized" }));
        return service.Send(userId, request);
    }

    [HttpPost("{messageId:int}/read")]
    public Task<ActionResult> MarkRead(int messageId)
    {
        if (!TryResolveUserId(out var userId))
            return Task.FromResult<ActionResult>(Unauthorized(new { message = "Unauthorized" }));
        return service.MarkRead(userId, messageId);
    }

    private bool TryResolveUserId(out int userId)
    {
        userId = 0;
        var header = HttpContext.Request.Headers.Authorization.ToString();
        var token = string.IsNullOrWhiteSpace(header) ? HttpContext.Request.Headers["X-Access-Token"].ToString() : header.Trim();
        if (string.IsNullOrWhiteSpace(token)) return false;

        try
        {
            var jwt = new JwtSecurityTokenHandler().ReadJwtToken(token);
            var rawUserId = jwt.Claims.FirstOrDefault(c => c.Type == "userId")?.Value;
            return int.TryParse(rawUserId, out userId);
        }
        catch
        {
            return false;
        }
    }
}
