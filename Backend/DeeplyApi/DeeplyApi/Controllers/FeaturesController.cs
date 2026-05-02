using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace DeeplyApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FeaturesController : ControllerBase
{
    private readonly IFeatureService _service;

    public FeaturesController(IFeatureService service)
    {
        _service = service;
    }

    [HttpPost]
    [Route("memories")]
    public async Task<IActionResult> AddMemory(CreateMemoryRequest request)
    {
        return await ExecuteAuthorized(userId => _service.AddMemory(userId, request));
    }

    [HttpGet]
    [Route("memories")]
    public async Task<IActionResult> GetMemories([FromQuery] DateOnly? day = null)
    {
        return await ExecuteAuthorized(userId => _service.GetMemories(userId, day));
    }

    [HttpDelete]
    [Route("memories/{id:int}")]
    public async Task<IActionResult> DeleteMemory(int id)
    {
        return await ExecuteAuthorized(userId => _service.DeleteMemory(userId, id));
    }

    [HttpPost]
    [Route("calendar/events")]
    public async Task<IActionResult> CreateEvent(CreateEventRequest request)
    {
        return await ExecuteAuthorized(userId => _service.CreateEvent(userId, request));
    }

    [HttpGet]
    [Route("calendar/events")]
    public async Task<IActionResult> GetEvents()
    {
        return await ExecuteAuthorized(_service.GetEvents);
    }

    [HttpPost]
    [Route("mood")]
    public async Task<IActionResult> AddMood(CreateMoodRequest request)
    {
        return await ExecuteAuthorized(userId => _service.AddMood(userId, request));
    }

    [HttpGet]
    [Route("mood/weekly")]
    public async Task<IActionResult> WeeklyMood()
    {
        return await ExecuteAuthorized(_service.WeeklyMood);
    }

    [HttpGet]
    [Route("question/today")]
    public async Task<IActionResult> GetQuestionToday()
    {
        return await ExecuteAuthorized(_service.GetQuestionToday);
    }

    [HttpGet]
    [Route("challenges/active")]
    public async Task<IActionResult> GetActiveChallenge()
    {
        return await ExecuteAuthorized(_service.GetActiveChallenge);
    }

    [HttpGet]
    [Route("secret-messages/all")]
    public async Task<IActionResult> GetAllSecretMessages()
    {
        return await ExecuteAuthorized(_service.GetAllSecretMessages);
    }

    [HttpGet]
    [Route("checkin/weekly/status")]
    public async Task<IActionResult> GetCheckinStatus()
    {
        return await ExecuteAuthorized(_service.GetCheckinStatus);
    }

    [HttpPost]
    [Route("question/{questionId:int}/answer")]
    public async Task<IActionResult> AnswerQuestion(int questionId, AnswerQuestionRequest request)
    {
        return await ExecuteAuthorized(userId => _service.AnswerQuestion(userId, questionId, request));
    }

    [HttpPost]
    [Route("checkin/weekly")]
    public async Task<IActionResult> AddCheckIn(WeeklyCheckInRequest request)
    {
        return await ExecuteAuthorized(userId => _service.AddCheckIn(userId, request));
    }

    [HttpGet]
    [Route("challenges/templates")]
    public async Task<IActionResult> ChallengeTemplates()
    {
        return await _service.ChallengeTemplates();
    }

    [HttpPost]
    [Route("challenges/{templateId:int}/start")]
    public async Task<IActionResult> StartChallenge(int templateId)
    {
        return await ExecuteAuthorized(userId => _service.StartChallenge(userId, templateId));
    }

    [HttpPost]
    [Route("challenges/{challengeId:int}/days/{day}/done")]
    public async Task<IActionResult> MarkChallengeDay(int challengeId, DateOnly day)
    {
        return await ExecuteAuthorized(userId => _service.MarkChallengeDay(userId, challengeId, day));
    }

    [HttpPost]
    [Route("challenges/{challengeId:int}/complete")]
    public async Task<IActionResult> CompleteChallenge(int challengeId)
    {
        return await ExecuteAuthorized(userId => _service.CompleteChallenge(userId, challengeId));
    }

    [HttpPost]
    [Route("time-capsules")]
    public async Task<IActionResult> CreateCapsule(CreateTimeCapsuleRequest request)
    {
        return await ExecuteAuthorized(userId => _service.CreateCapsule(userId, request));
    }

    [HttpGet]
    [Route("time-capsules/opened")]
    public async Task<IActionResult> GetOpenedCapsules()
    {
        return await ExecuteAuthorized(_service.GetOpenedCapsules);
    }

    [HttpPost]
    [Route("secret-messages")]
    public async Task<IActionResult> CreateSecret(CreateSecretMessageRequest request)
    {
        return await ExecuteAuthorized(userId => _service.CreateSecret(userId, request));
    }

    [HttpGet]
    [Route("secret-messages")]
    public async Task<IActionResult> OpenedSecrets()
    {
        return await ExecuteAuthorized(_service.OpenedSecrets);
    }

    [HttpPost]
    [Route("love-map/points")]
    public async Task<IActionResult> AddLovePoint(CreateLovePointRequest request)
    {
        return await ExecuteAuthorized(userId => _service.AddLovePoint(userId, request));
    }

    [HttpGet]
    [Route("love-map/points")]
    public async Task<IActionResult> GetLovePoints()
    {
        return await ExecuteAuthorized(_service.GetLovePoints);
    }

    [HttpPost]
    [Route("todos")]
    public async Task<IActionResult> CreateTodo(CreateTodoRequest request)
    {
        return await ExecuteAuthorized(userId => _service.CreateTodo(userId, request));
    }

    [HttpPatch]
    [Route("todos/{id:int}/status")]
    public async Task<IActionResult> UpdateTodoStatus(int id, UpdateTodoStatusRequest request)
    {
        return await ExecuteAuthorized(userId => _service.UpdateTodoStatus(userId, id, request));
    }

    [HttpGet]
    [Route("todos")]
    public async Task<IActionResult> GetTodos()
    {
        return await ExecuteAuthorized(_service.GetTodos);
    }

    [HttpPost]
    [Route("finance/records")]
    public async Task<IActionResult> AddFinanceRecord(CreateFinanceRecordRequest request)
    {
        return await ExecuteAuthorized(userId => _service.AddFinanceRecord(userId, request));
    }

    [HttpGet]
    [Route("finance/summary")]
    public async Task<IActionResult> FinanceSummary()
    {
        return await ExecuteAuthorized(_service.FinanceSummary);
    }

    [HttpPost]
    [Route("finance/goals")]
    public async Task<IActionResult> AddGoal(CreateFinanceGoalRequest request)
    {
        return await ExecuteAuthorized(userId => _service.AddGoal(userId, request));
    }

    [HttpPost]
    [Route("attachment-test")]
    public async Task<IActionResult> AttachmentTest(AttachmentTestRequest request)
    {
        return await ExecuteAuthorized(userId => _service.AttachmentTest(userId, request));
    }

    [HttpGet]
    [Route("closeness-index")]
    public async Task<IActionResult> ClosenessIndex()
    {
        return await ExecuteAuthorized(_service.ClosenessIndex);
    }

    private async Task<IActionResult> ExecuteAuthorized(Func<int, Task<ActionResult>> action)
    {
        if (!TryResolveUserId(out var userId))
            return Unauthorized(new { message = "Unauthorized" });
        return await action(userId);
    }

    private async Task<IActionResult> ExecuteAuthorized(Func<Task<ActionResult>> action)
    {
        if (!TryResolveUserId(out _))
            return Unauthorized(new { message = "Unauthorized" });
        return await action();
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
