using DeeplyApi.Requests;
using Microsoft.AspNetCore.Mvc;

namespace DeeplyApi.Interfaces;

public interface IFeatureService
{
    Task<ActionResult> AddMemory(int userId, CreateMemoryRequest request);
    Task<ActionResult> GetMemories(int userId, DateOnly? day);
    Task<ActionResult> DeleteMemory(int userId, int id);
    Task<ActionResult> CreateEvent(int userId, CreateEventRequest request);
    Task<ActionResult> GetEvents(int userId);
    Task<ActionResult> AddMood(int userId, CreateMoodRequest request);
    Task<ActionResult> WeeklyMood(int userId);
    Task<ActionResult> GetQuestionToday(int userId);
    Task<ActionResult> GetQuestionWithAnswers(int userId);
    Task<ActionResult> GetActiveChallenge(int userId);
    Task<ActionResult> GetAllSecretMessages(int userId);
    Task<ActionResult> GetCheckinStatus(int userId);
    Task<ActionResult> AnswerQuestion(int userId, int questionId, AnswerQuestionRequest request);
    Task<ActionResult> AddCheckIn(int userId, WeeklyCheckInRequest request);
    Task<ActionResult> ChallengeTemplates();
    Task<ActionResult> StartChallenge(int userId, int templateId);
    Task<ActionResult> MarkChallengeDay(int userId, int challengeId, DateOnly day);
    Task<ActionResult> CompleteChallenge(int userId, int challengeId);
    Task<ActionResult> CreateCapsule(int userId, CreateTimeCapsuleRequest request);
    Task<ActionResult> GetOpenedCapsules(int userId);
    Task<ActionResult> CreateSecret(int userId, CreateSecretMessageRequest request);
    Task<ActionResult> OpenedSecrets(int userId);
    Task<ActionResult> AddLovePoint(int userId, CreateLovePointRequest request);
    Task<ActionResult> GetLovePoints(int userId);
    Task<ActionResult> CreateTodo(int userId, CreateTodoRequest request);
    Task<ActionResult> UpdateTodoStatus(int userId, int id, UpdateTodoStatusRequest request);
    Task<ActionResult> GetTodos(int userId);
    Task<ActionResult> AddFinanceRecord(int userId, CreateFinanceRecordRequest request);
    Task<ActionResult> FinanceSummary(int userId);
    Task<ActionResult> AddGoal(int userId, CreateFinanceGoalRequest request);
    Task<ActionResult> AttachmentTest(int userId, AttachmentTestRequest request);
    Task<ActionResult> GetAttachmentTestResult(int userId);
    Task<ActionResult> ClosenessIndex(int userId);
}
