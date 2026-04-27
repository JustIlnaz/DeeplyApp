using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace DeeplyApi.Controllers;

[Route("api/features")]
[ApiController]
public class FeaturesController(IFeatureService service) : ControllerBase
{
    private ActionResult UnauthorizedResponse() => Unauthorized(new { message = "Unauthorized" });

    private Task<ActionResult> ExecuteAuthorized(Func<int, Task<ActionResult>> action)
    {
        if (!TryUser(out var userId))
            return Task.FromResult<ActionResult>(UnauthorizedResponse());
        return action(userId);
    }

    private bool TryUser(out int userId)
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

    [HttpPost("memories")] public Task<ActionResult> AddMemory(CreateMemoryRequest request) => ExecuteAuthorized(userId => service.AddMemory(userId, request));
    [HttpGet("memories")] public Task<ActionResult> GetMemories([FromQuery] DateOnly? day = null) => ExecuteAuthorized(userId => service.GetMemories(userId, day));
    [HttpDelete("memories/{id:int}")] public Task<ActionResult> DeleteMemory(int id) => ExecuteAuthorized(userId => service.DeleteMemory(userId, id));
    [HttpPost("calendar/events")] public Task<ActionResult> CreateEvent(CreateEventRequest request) => ExecuteAuthorized(userId => service.CreateEvent(userId, request));
    [HttpGet("calendar/events")] public Task<ActionResult> GetEvents() => ExecuteAuthorized(service.GetEvents);
    [HttpPost("mood")] public Task<ActionResult> AddMood(CreateMoodRequest request) => ExecuteAuthorized(userId => service.AddMood(userId, request));
    [HttpGet("mood/weekly")] public Task<ActionResult> WeeklyMood() => ExecuteAuthorized(service.WeeklyMood);
    [HttpGet("question/today")] public Task<ActionResult> GetQuestionToday() => service.GetQuestionToday();
    [HttpPost("question/{questionId:int}/answer")] public Task<ActionResult> AnswerQuestion(int questionId, AnswerQuestionRequest request) => ExecuteAuthorized(userId => service.AnswerQuestion(userId, questionId, request));
    [HttpPost("checkin/weekly")] public Task<ActionResult> AddCheckIn(WeeklyCheckInRequest request) => ExecuteAuthorized(userId => service.AddCheckIn(userId, request));
    [HttpGet("challenges/templates")] public Task<ActionResult> ChallengeTemplates() => service.ChallengeTemplates();
    [HttpPost("challenges/{templateId:int}/start")] public Task<ActionResult> StartChallenge(int templateId) => ExecuteAuthorized(userId => service.StartChallenge(userId, templateId));
    [HttpPost("challenges/{challengeId:int}/days/{day}/done")] public Task<ActionResult> MarkChallengeDay(int challengeId, DateOnly day) => ExecuteAuthorized(userId => service.MarkChallengeDay(userId, challengeId, day));
    [HttpPost("challenges/{challengeId:int}/complete")] public Task<ActionResult> CompleteChallenge(int challengeId) => ExecuteAuthorized(userId => service.CompleteChallenge(userId, challengeId));
    [HttpPost("time-capsules")] public Task<ActionResult> CreateCapsule(CreateTimeCapsuleRequest request) => ExecuteAuthorized(userId => service.CreateCapsule(userId, request));
    [HttpGet("time-capsules/opened")] public Task<ActionResult> GetOpenedCapsules() => ExecuteAuthorized(service.GetOpenedCapsules);
    [HttpPost("secret-messages")] public Task<ActionResult> CreateSecret(CreateSecretMessageRequest request) => ExecuteAuthorized(userId => service.CreateSecret(userId, request));
    [HttpGet("secret-messages")] public Task<ActionResult> OpenedSecrets() => ExecuteAuthorized(service.OpenedSecrets);
    [HttpPost("love-map/points")] public Task<ActionResult> AddLovePoint(CreateLovePointRequest request) => ExecuteAuthorized(userId => service.AddLovePoint(userId, request));
    [HttpGet("love-map/points")] public Task<ActionResult> GetLovePoints() => ExecuteAuthorized(service.GetLovePoints);
    [HttpPost("todos")] public Task<ActionResult> CreateTodo(CreateTodoRequest request) => ExecuteAuthorized(userId => service.CreateTodo(userId, request));
    [HttpPatch("todos/{id:int}/status")] public Task<ActionResult> UpdateTodoStatus(int id, UpdateTodoStatusRequest request) => ExecuteAuthorized(userId => service.UpdateTodoStatus(userId, id, request));
    [HttpGet("todos")] public Task<ActionResult> GetTodos() => ExecuteAuthorized(service.GetTodos);
    [HttpPost("finance/records")] public Task<ActionResult> AddFinanceRecord(CreateFinanceRecordRequest request) => ExecuteAuthorized(userId => service.AddFinanceRecord(userId, request));
    [HttpGet("finance/summary")] public Task<ActionResult> FinanceSummary() => ExecuteAuthorized(service.FinanceSummary);
    [HttpPost("finance/goals")] public Task<ActionResult> AddGoal(CreateFinanceGoalRequest request) => ExecuteAuthorized(userId => service.AddGoal(userId, request));
    [HttpPost("attachment-test")] public Task<ActionResult> AttachmentTest(AttachmentTestRequest request) => ExecuteAuthorized(userId => service.AttachmentTest(userId, request));
    [HttpGet("closeness-index")] public Task<ActionResult> ClosenessIndex() => ExecuteAuthorized(service.ClosenessIndex);
}
