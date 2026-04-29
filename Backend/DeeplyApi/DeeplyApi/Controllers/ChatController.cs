using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace DeeplyApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ChatController : ControllerBase
{
    private readonly IChatService _service;

    public ChatController(IChatService service)
    {
        _service = service;
    }

    [HttpGet]
    [Route("history")]
    public async Task<IActionResult> History([FromQuery] int take = 50)
    {
        return await ExecuteAuthorized(userId => _service.History(userId, take));
    }

    [HttpPost]
    [Route("send")]
    public async Task<IActionResult> Send([FromBody] CreateChatMessageRequest request)
    {
        return await ExecuteAuthorized(userId => _service.Send(userId, request));
    }

    [HttpPost]
    [Route("{messageId:int}/read")]
    public async Task<IActionResult> MarkRead(int messageId)
    {
        return await ExecuteAuthorized(userId => _service.MarkRead(userId, messageId));
    }

    private async Task<IActionResult> ExecuteAuthorized(Func<int, Task<ActionResult>> action)
    {
        if (!TryResolveUserId(out var userId))
            return Unauthorized(new { message = "Unauthorized" });
        return await action(userId);
    }

    private bool TryResolveUserId(out int userId)
    {
        userId = 0;
        var header = HttpContext.Request.Headers.Authorization.ToString();
        var token = string.IsNullOrWhiteSpace(header) ? HttpContext.Request.Headers["Authorization"].ToString() : header.Trim();
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
