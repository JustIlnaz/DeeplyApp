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
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> AddMemory([FromForm] CreateMemoryRequest request)
    {
        Console.WriteLine($"=== CONTROLLER AddMemory ===");
        Console.WriteLine($"Request Photo null: {request.Photo == null}");
        Console.WriteLine($"Request Video null: {request.Video == null}");
        Console.WriteLine($"Request Text: {request.Text}");
        if (request.Photo != null)
        {
            Console.WriteLine($"Photo FileName: {request.Photo.FileName}, Length: {request.Photo.Length}");
        }
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
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> AddLovePoint([FromForm] CreateLovePointRequest request)
    {
        Console.WriteLine($"=== CONTROLLER AddLovePoint ===");
        Console.WriteLine($"Lat: {request.Latitude}, Lng: {request.Longitude}");
        Console.WriteLine($"Photo null: {request.Photo == null}, Video null: {request.Video == null}");
        if (request.Photo != null)
            Console.WriteLine($"Photo: {request.Photo.FileName}, {request.Photo.Length} bytes");
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
    [Route("attachment-test/result")]
    public async Task<IActionResult> GetAttachmentTestResult()
    {
        return await ExecuteAuthorized(userId => _service.GetAttachmentTestResult(userId));
    }

    [HttpGet]
    [Route("closeness-index")]
    public async Task<IActionResult> ClosenessIndex()
    {
        return await ExecuteAuthorized(_service.ClosenessIndex);
    }

    [HttpGet]
    [Route("test-uploads")]
    public IActionResult TestUploads()
    {
        var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
        var memoriesPath = Path.Combine(uploadsPath, "memories");
        var lovemapPath = Path.Combine(uploadsPath, "lovemap");
        
        var result = new
        {
            uploadsPathExists = Directory.Exists(uploadsPath),
            memoriesPathExists = Directory.Exists(memoriesPath),
            lovemapPathExists = Directory.Exists(lovemapPath),
            memoriesFiles = Directory.Exists(memoriesPath) ? Directory.GetFiles(memoriesPath).Select(f => Path.GetFileName(f)).ToList() : new List<string>(),
            lovemapFiles = Directory.Exists(lovemapPath) ? Directory.GetFiles(lovemapPath).Select(f => Path.GetFileName(f)).ToList() : new List<string>(),
            currentDirectory = Directory.GetCurrentDirectory()
        };
        
        return Ok(result);
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
        Console.WriteLine($"[Auth] Authorization header: {header?.Substring(0, Math.Min(50, header?.Length ?? 0))}...");
        
        if (string.IsNullOrWhiteSpace(header)) return false;
        
        // Убираем префикс "Bearer "
        var token = header.Trim();
        if (token.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            token = token.Substring(7).Trim();
        
        Console.WriteLine($"[Auth] Token after Bearer removal: {token?.Substring(0, Math.Min(50, token?.Length ?? 0))}...");
        
        if (string.IsNullOrWhiteSpace(token)) return false;

        try
        {
            var jwt = new JwtSecurityTokenHandler().ReadJwtToken(token);
            var rawUserId = jwt.Claims.FirstOrDefault(c => c.Type == "userId")?.Value;
            Console.WriteLine($"[Auth] Found userId claim: {rawUserId}");
            var result = int.TryParse(rawUserId, out userId);
            Console.WriteLine($"[Auth] Parse result: {result}, userId: {userId}");
            return result;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[Auth] Exception: {ex.Message}");
            return false;
        }
    }
}
