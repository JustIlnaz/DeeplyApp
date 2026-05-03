using DeeplyApi.Requests;
using Microsoft.AspNetCore.Mvc;

namespace DeeplyApi.Interfaces;

public interface IAuthService
{
    Task<ActionResult> Register(RegisterRequest request);
    Task<ActionResult> Login(LoginRequest request);
    Task<ActionResult> Refresh(RefreshRequest request);
    Task<ActionResult> GetCurrentUser(System.Security.Claims.ClaimsPrincipal principal);
}
