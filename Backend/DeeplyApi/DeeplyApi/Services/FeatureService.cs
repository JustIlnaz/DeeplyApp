using DeeplyApi.Connection;
using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using DeeplyApi.Models;
using Hangfire;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DeeplyApi.Services;

public class FeatureService(AppDbContext db, IBackgroundJobClient jobs) : IFeatureService
{
    public async Task<ActionResult> AddMemory(int userId, CreateMemoryRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var entry = new MemoryEntry { CoupleId = couple.Id, Text = request.Text, PhotoUrl = request.PhotoUrl, VideoUrl = request.VideoUrl, IsPinned = request.IsPinned };
        db.MemoryEntries.Add(entry);
        await db.SaveChangesAsync();
        return new OkObjectResult(entry);
    }

    public async Task<ActionResult> GetMemories(int userId, DateOnly? day)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var query = db.MemoryEntries.Where(x => x.CoupleId == couple.Id);
        if (day.HasValue) query = query.Where(x => DateOnly.FromDateTime(x.CreatedAtUtc) == day.Value);
        return new OkObjectResult(await query.OrderByDescending(x => x.IsPinned).ThenByDescending(x => x.CreatedAtUtc).ToListAsync());
    }

    public async Task<ActionResult> DeleteMemory(int userId, int id)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var item = await db.MemoryEntries.FirstOrDefaultAsync(x => x.Id == id && x.CoupleId == couple.Id);
        if (item is null) return new NotFoundResult();
        db.MemoryEntries.Remove(item);
        await db.SaveChangesAsync();
        return new OkResult();
    }

    public async Task<ActionResult> CreateEvent(int userId, CreateEventRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var e = new CoupleEvent { CoupleId = couple.Id, Title = request.Title, Description = request.Description, StartsAtUtc = request.StartsAtUtc, EndsAtUtc = request.EndsAtUtc, ReminderAtUtc = request.ReminderAtUtc };
        db.CoupleEvents.Add(e);
        await db.SaveChangesAsync();
        if (e.ReminderAtUtc.HasValue && e.ReminderAtUtc > DateTime.UtcNow) jobs.Schedule(() => Console.WriteLine($"Reminder event {e.Id}"), e.ReminderAtUtc.Value - DateTime.UtcNow);
        return new OkObjectResult(e);
    }

    public async Task<ActionResult> GetEvents(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        return new OkObjectResult(await db.CoupleEvents.Where(x => x.CoupleId == couple.Id).OrderBy(x => x.StartsAtUtc).ToListAsync());
    }

    public async Task<ActionResult> AddMood(int userId, CreateMoodRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var day = DateOnly.FromDateTime(DateTime.UtcNow);
        var exists = await db.MoodEntries.AnyAsync(x => x.UserId == userId && x.Day == day);
        if (exists) return new BadRequestObjectResult(new { message = "Only one mood entry per day" });
        var mood = new MoodEntry { UserId = userId, CoupleId = couple.Id, Day = day, MoodType = request.MoodType, Comment = request.Comment };
        db.MoodEntries.Add(mood);
        await db.SaveChangesAsync();
        return new OkObjectResult(mood);
    }

    public async Task<ActionResult> WeeklyMood(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var from = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-6));
        return new OkObjectResult(await db.MoodEntries.Where(x => x.CoupleId == couple.Id && x.Day >= from).OrderBy(x => x.Day).ToListAsync());
    }

    public async Task<ActionResult> GetQuestionToday()
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var q = await db.DailyQuestions.FirstOrDefaultAsync(x => x.Day == today);
        if (q is null)
        {
            q = new DailyQuestion { Day = today, Category = "deep", Text = "What made you feel loved today?" };
            db.DailyQuestions.Add(q);
            await db.SaveChangesAsync();
        }
        return new OkObjectResult(q);
    }

    public async Task<ActionResult> AnswerQuestion(int userId, int questionId, AnswerQuestionRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var q = await db.DailyQuestions.FindAsync(questionId);
        if (q is null) return new NotFoundResult();
        var answer = new DailyQuestionAnswer { QuestionId = questionId, UserId = userId, CoupleId = couple.Id, Answer = request.Answer };
        db.DailyQuestionAnswers.Add(answer);
        await db.SaveChangesAsync();
        var bothAnswered = await db.DailyQuestionAnswers.CountAsync(x => x.QuestionId == questionId && x.CoupleId == couple.Id) >= 2;
        return new OkObjectResult(new { bothAnswered });
    }

    public async Task<ActionResult> AddCheckIn(int userId, WeeklyCheckInRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var now = DateTime.UtcNow.Date;
        var monday = DateOnly.FromDateTime(now.AddDays(-((int)now.DayOfWeek + 6) % 7));
        db.WeeklyCheckIns.Add(new WeeklyCheckIn { CoupleId = couple.Id, UserId = userId, WeekStart = monday, WhatWasGreat = request.WhatWasGreat, WhereWasTension = request.WhereWasTension, WhatToImprove = request.WhatToImprove });
        await db.SaveChangesAsync();
        var both = await db.WeeklyCheckIns.CountAsync(x => x.CoupleId == couple.Id && x.WeekStart == monday) >= 2;
        return new OkObjectResult(new { bothCompleted = both });
    }

    public async Task<ActionResult> ChallengeTemplates() => new OkObjectResult(await db.ChallengeTemplates.OrderBy(x => x.Title).ToListAsync());

    public async Task<ActionResult> StartChallenge(int userId, int templateId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var template = await db.ChallengeTemplates.FindAsync(templateId);
        if (template is null) return new NotFoundResult();
        var current = await db.CoupleChallenges.FirstOrDefaultAsync(x => x.CoupleId == couple.Id && !x.IsCompleted);
        if (current is not null) return new BadRequestObjectResult(new { message = "Active challenge already exists" });
        var cc = new CoupleChallenge { CoupleId = couple.Id, TemplateId = template.Id, StartedOn = DateOnly.FromDateTime(DateTime.UtcNow) };
        db.CoupleChallenges.Add(cc);
        await db.SaveChangesAsync();
        return new OkObjectResult(cc);
    }

    public async Task<ActionResult> MarkChallengeDay(int userId, int challengeId, DateOnly day)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var challenge = await db.CoupleChallenges.FirstOrDefaultAsync(x => x.Id == challengeId && x.CoupleId == couple.Id);
        if (challenge is null) return new NotFoundResult();
        var progress = await db.ChallengeProgresses.FirstOrDefaultAsync(x => x.CoupleChallengeId == challengeId && x.Day == day);
        if (progress is null) db.ChallengeProgresses.Add(new ChallengeProgress { CoupleChallengeId = challengeId, Day = day, Done = true });
        else progress.Done = true;
        await db.SaveChangesAsync();
        return new OkObjectResult(new { message = "Progress updated" });
    }

    public async Task<ActionResult> CompleteChallenge(int userId, int challengeId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var challenge = await db.CoupleChallenges.FirstOrDefaultAsync(x => x.Id == challengeId && x.CoupleId == couple.Id);
        if (challenge is null) return new NotFoundResult();
        challenge.IsCompleted = true;
        await db.SaveChangesAsync();
        return new OkObjectResult(challenge);
    }

    public async Task<ActionResult> CreateCapsule(int userId, CreateTimeCapsuleRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var item = new TimeCapsule { CoupleId = couple.Id, Letter = request.Letter, OpenAtUtc = request.OpenAtUtc };
        db.TimeCapsules.Add(item);
        await db.SaveChangesAsync();
        return new OkObjectResult(item);
    }

    public async Task<ActionResult> GetOpenedCapsules(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        return new OkObjectResult(await db.TimeCapsules.Where(x => x.CoupleId == couple.Id && x.OpenAtUtc <= DateTime.UtcNow).ToListAsync());
    }

    public async Task<ActionResult> CreateSecret(int userId, CreateSecretMessageRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var item = new SecretMessage { CoupleId = couple.Id, SenderUserId = userId, Message = request.Message, OpenAtUtc = request.OpenAtUtc };
        db.SecretMessages.Add(item);
        await db.SaveChangesAsync();
        return new OkObjectResult(item);
    }

    public async Task<ActionResult> OpenedSecrets(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        return new OkObjectResult(await db.SecretMessages.Where(x => x.CoupleId == couple.Id && x.OpenAtUtc <= DateTime.UtcNow).ToListAsync());
    }

    public async Task<ActionResult> AddLovePoint(int userId, CreateLovePointRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var point = new LoveMapPoint { CoupleId = couple.Id, Latitude = request.Latitude, Longitude = request.Longitude, PhotoUrl = request.PhotoUrl, Description = request.Description };
        db.LoveMapPoints.Add(point);
        await db.SaveChangesAsync();
        return new OkObjectResult(point);
    }

    public async Task<ActionResult> GetLovePoints(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        return new OkObjectResult(await db.LoveMapPoints.Where(x => x.CoupleId == couple.Id).ToListAsync());
    }

    public async Task<ActionResult> CreateTodo(int userId, CreateTodoRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var todo = new CoupleTodo { CoupleId = couple.Id, Title = request.Title, ResponsibleUserId = request.ResponsibleUserId };
        db.CoupleTodos.Add(todo);
        await db.SaveChangesAsync();
        return new OkObjectResult(todo);
    }

    public async Task<ActionResult> UpdateTodoStatus(int userId, int id, UpdateTodoStatusRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var todo = await db.CoupleTodos.FirstOrDefaultAsync(x => x.Id == id && x.CoupleId == couple.Id);
        if (todo is null) return new NotFoundResult();
        todo.Status = request.Status;
        await db.SaveChangesAsync();
        return new OkObjectResult(todo);
    }

    public async Task<ActionResult> GetTodos(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        return new OkObjectResult(await db.CoupleTodos.Where(x => x.CoupleId == couple.Id).OrderBy(x => x.CreatedAtUtc).ToListAsync());
    }

    public async Task<ActionResult> AddFinanceRecord(int userId, CreateFinanceRecordRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var record = new FinanceRecord { CoupleId = couple.Id, Type = request.Type, Category = request.Category, Amount = request.Amount, DateUtc = request.DateUtc };
        db.FinanceRecords.Add(record);
        await db.SaveChangesAsync();
        return new OkObjectResult(record);
    }

    public async Task<ActionResult> FinanceSummary(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var records = await db.FinanceRecords.Where(x => x.CoupleId == couple.Id).ToListAsync();
        var income = records.Where(x => x.Type == "income").Sum(x => x.Amount);
        var expense = records.Where(x => x.Type == "expense").Sum(x => x.Amount);
        return new OkObjectResult(new { income, expense, balance = income - expense });
    }

    public async Task<ActionResult> AddGoal(int userId, CreateFinanceGoalRequest request)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var goal = new FinanceGoal { CoupleId = couple.Id, Title = request.Title, TargetAmount = request.TargetAmount, CurrentAmount = 0 };
        db.FinanceGoals.Add(goal);
        await db.SaveChangesAsync();
        return new OkObjectResult(goal);
    }

    public async Task<ActionResult> AttachmentTest(int userId, AttachmentTestRequest request)
    {
        var sum = request.Answers.Sum();
        var type = sum <= 40 ? "secure" : (sum <= 65 ? "anxious" : "avoidant");
        var recommendation = type switch
        {
            "secure" => "Continue regular emotional check-ins and shared rituals.",
            "anxious" => "Work on reassurance rituals and calm conflict responses.",
            _ => "Practice emotional openness and predictable communication."
        };
        var result = new AttachmentTestResult { UserId = userId, AttachmentType = type, Recommendation = recommendation };
        db.AttachmentTestResults.Add(result);
        await db.SaveChangesAsync();
        return new OkObjectResult(result);
    }

    public async Task<ActionResult> ClosenessIndex(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var from = DateTime.UtcNow.AddDays(-7);
        var chats = await db.ChatMessages.CountAsync(x => x.CoupleId == couple.Id && x.SentAtUtc >= from);
        var checkins = await db.WeeklyCheckIns.CountAsync(x => x.CoupleId == couple.Id);
        var answers = await db.DailyQuestionAnswers.CountAsync(x => x.CoupleId == couple.Id && x.CreatedAtUtc >= from);
        var progress = await db.ChallengeProgresses.CountAsync();
        return new OkObjectResult(new { score = Math.Min(100, chats + checkins * 8 + answers * 3 + progress * 2) });
    }

    private Task<Couple?> GetCouple(int userId) =>
        db.Couples.FirstOrDefaultAsync(x => x.User1Id == userId || x.User2Id == userId);
}
