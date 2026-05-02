using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace DeeplyApi.Controllers;

[Route("api/couples")]
public class CouplesController(ICoupleService service) : ControllerBase
{
    [HttpPost("create")]
    public Task<ActionResult> Create([FromBody] CreateCoupleRequest request)
    {
        if (!TryResolveUserId(out var userId))
            return Task.FromResult<ActionResult>(Unauthorized(new { message = "Unauthorized" }));
        return service.Create(userId, request);
    }

    [HttpPost("join")]
    public Task<ActionResult> Join([FromBody] JoinCoupleRequest request)
    {
        if (!TryResolveUserId(out var userId))
            return Task.FromResult<ActionResult>(Unauthorized(new { message = "Unauthorized" }));
        return service.Join(userId, request);
    }

    [HttpGet("me")]
    public Task<ActionResult> GetMyCouple()
    {
        if (!TryResolveUserId(out var userId))
            return Task.FromResult<ActionResult>(Unauthorized(new { message = "Unauthorized" }));
        return service.GetMyCouple(userId);
    }

    private bool TryResolveUserId(out int userId)
    {
        userId = 0;
        var token = HttpContext.Request.Headers.Authorization.ToString().Trim();
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
