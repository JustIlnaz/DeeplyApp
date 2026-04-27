using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using DeeplyApi.Services;
using Microsoft.AspNetCore.Mvc;

namespace DeeplyApi.Controllers;

[Route("api/auth")]
public class AuthController(IAuthService service) : ControllerBase
{
    [HttpPost("register")]
    public Task<ActionResult> Register([FromBody] RegisterRequest request) => service.Register(request);

    [HttpPost("login")]
    public Task<ActionResult> Login([FromBody] LoginRequest request) => service.Login(request);

    [HttpPost("refresh")]
    public Task<ActionResult> Refresh([FromBody] RefreshRequest request) => service.Refresh(request);
}
