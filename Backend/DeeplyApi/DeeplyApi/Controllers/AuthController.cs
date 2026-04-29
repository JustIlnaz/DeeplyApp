using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using DeeplyApi.Services;
using Microsoft.AspNetCore.Mvc;

namespace DeeplyApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _service;
    
    public AuthController(IAuthService service)
    {
        _service = service;
    }

    [HttpPost]
    [Route("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        return await _service.Register(request);
    }

    [HttpPost]
    [Route("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        return await _service.Login(request);
    }

    [HttpPost]
    [Route("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
    {
        return await _service.Refresh(request);
    }
}
