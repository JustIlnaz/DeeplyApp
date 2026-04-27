using DeeplyApi.Connection;
using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using DeeplyApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DeeplyApi.Services;

public class AuthService(AppDbContext db, JwtService jwtService) : IAuthService
{
    public async Task<ActionResult> Register(RegisterRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            return new BadRequestObjectResult(new { message = "Email and password are required" });

        var email = request.Email.Trim().ToLower();
        var exists = await db.Users.AnyAsync(x => x.Email == email);
        if (exists) return new BadRequestObjectResult(new { message = "User already exists" });

        var user = new User
        {
            Email = email,
            Name = request.Name.Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password)
        };
        db.Users.Add(user);
        await db.SaveChangesAsync();
        return new OkObjectResult(new { user.Id, user.Email, user.Name });
    }

    public async Task<ActionResult> Login(LoginRequest request)
    {
        var email = request.Email.Trim().ToLower();
        var user = await db.Users.FirstOrDefaultAsync(x => x.Email == email);
        if (user is null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return new UnauthorizedObjectResult(new { message = "Invalid credentials" });

        var refresh = new RefreshToken
        {
            UserId = user.Id,
            Token = jwtService.GenerateRefreshToken(),
            ExpiresAtUtc = DateTime.UtcNow.AddDays(30)
        };
        db.RefreshTokens.Add(refresh);
        await db.SaveChangesAsync();
        return new OkObjectResult(new { accessToken = jwtService.GenerateToken(user), refreshToken = refresh.Token });
    }

    public async Task<ActionResult> Refresh(RefreshRequest request)
    {
        var token = await db.RefreshTokens.FirstOrDefaultAsync(x => x.Token == request.RefreshToken && !x.IsRevoked);
        if (token is null || token.ExpiresAtUtc < DateTime.UtcNow)
            return new UnauthorizedObjectResult(new { message = "Invalid refresh token" });

        var user = await db.Users.FindAsync(token.UserId);
        if (user is null) return new UnauthorizedObjectResult(new { message = "User not found" });

        token.IsRevoked = true;
        var newRefresh = new RefreshToken
        {
            UserId = user.Id,
            Token = jwtService.GenerateRefreshToken(),
            ExpiresAtUtc = DateTime.UtcNow.AddDays(30)
        };
        db.RefreshTokens.Add(newRefresh);
        await db.SaveChangesAsync();
        return new OkObjectResult(new { accessToken = jwtService.GenerateToken(user), refreshToken = newRefresh.Token });
    }
}
