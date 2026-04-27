using DeeplyApi.Connection;
using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using DeeplyApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;

namespace DeeplyApi.Services;

public class CoupleService(AppDbContext db) : ICoupleService
{
    public async Task<ActionResult> Create(int userId, CreateCoupleRequest request)
    {
        var alreadyInCouple = await db.Couples.AnyAsync(x => x.User1Id == userId || x.User2Id == userId);
        if (alreadyInCouple) return new BadRequestObjectResult(new { message = "User can only belong to one couple" });

        var couple = new Couple
        {
            User1Id = userId,
            InviteCode = Convert.ToHexString(RandomNumberGenerator.GetBytes(4)),
            AnniversaryDate = request.AnniversaryDate
        };
        db.Couples.Add(couple);
        await db.SaveChangesAsync();
        return new OkObjectResult(new { couple.Id, couple.InviteCode });
    }

    public async Task<ActionResult> Join(int userId, JoinCoupleRequest request)
    {
        var alreadyInCouple = await db.Couples.AnyAsync(x => x.User1Id == userId || x.User2Id == userId);
        if (alreadyInCouple) return new BadRequestObjectResult(new { message = "User can only belong to one couple" });

        var couple = await db.Couples.FirstOrDefaultAsync(x => x.InviteCode == request.InviteCode.ToUpper());
        if (couple is null) return new NotFoundObjectResult(new { message = "Invite code not found" });
        if (couple.User2Id.HasValue) return new BadRequestObjectResult(new { message = "Couple already complete" });
        if (couple.User1Id == userId) return new BadRequestObjectResult(new { message = "Cannot join your own invite" });

        couple.User2Id = userId;
        await db.SaveChangesAsync();
        return new OkObjectResult(new { message = "Connected successfully", coupleId = couple.Id });
    }

    public async Task<ActionResult> GetMyCouple(int userId)
    {
        var couple = await db.Couples.FirstOrDefaultAsync(x => x.User1Id == userId || x.User2Id == userId);
        if (couple is null) return new NotFoundObjectResult(new { message = "Couple not found" });
        return new OkObjectResult(couple);
    }
}
