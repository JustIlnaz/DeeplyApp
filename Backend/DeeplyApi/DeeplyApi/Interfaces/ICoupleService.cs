using DeeplyApi.Requests;
using Microsoft.AspNetCore.Mvc;

namespace DeeplyApi.Interfaces;

public interface ICoupleService
{
    Task<ActionResult> Create(int userId, CreateCoupleRequest request);
    Task<ActionResult> Join(int userId, JoinCoupleRequest request);
    Task<ActionResult> GetMyCouple(int userId);
}
