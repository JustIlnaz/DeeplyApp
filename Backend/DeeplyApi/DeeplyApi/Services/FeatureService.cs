using DeeplyApi.Connection;
using DeeplyApi.Requests;
using DeeplyApi.Interfaces;
using DeeplyApi.Models;
using Hangfire;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DeeplyApi.Services;

public class FeatureService(AppDbContext db, IBackgroundJobClient jobs, ILogger<FeatureService> logger) : IFeatureService
{
    public async Task<ActionResult> AddMemory(int userId, CreateMemoryRequest request)
    {
        logger.LogInformation("=== AddMemory START ===");
        logger.LogInformation("UserId: {UserId}, Text: {Text}, IsPinned: {IsPinned}", userId, request.Text, request.IsPinned);
        logger.LogInformation("Photo is null: {PhotoIsNull}, Video is null: {VideoIsNull}", request.Photo == null, request.Video == null);
        
        var couple = await GetCouple(userId);
        if (couple is null) 
        {
            logger.LogWarning("No couple found for user {UserId}", userId);
            return new BadRequestObjectResult(new { message = "No couple connected" });
        }
        
        string? photoUrl = null;
        string? videoUrl = null;
        
        // Save photo if provided
        if (request.Photo != null)
        {
            logger.LogInformation("Photo received: Name={Name}, Length={Length}, ContentType={ContentType}", 
                request.Photo.FileName, request.Photo.Length, request.Photo.ContentType);
            
            var photoExt = Path.GetExtension(request.Photo.FileName);
            var photoFileName = $"{Guid.NewGuid()}{photoExt}";
            var photoPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "memories", photoFileName);
            
            logger.LogInformation("Saving photo to: {Path}", photoPath);
            
            Directory.CreateDirectory(Path.GetDirectoryName(photoPath)!);
            using (var stream = new FileStream(photoPath, FileMode.Create))
            {
                await request.Photo.CopyToAsync(stream);
            }
            
            // Проверяем что файл сохранился
            var fileInfo = new FileInfo(photoPath);
            logger.LogInformation("Photo saved: Exists={Exists}, Size={Size}", fileInfo.Exists, fileInfo.Length);
            
            photoUrl = $"/uploads/memories/{photoFileName}";
        }
        else
        {
            logger.LogWarning("Photo is NULL!");
        }
        
        // Save video if provided
        if (request.Video != null)
        {
            var videoExt = Path.GetExtension(request.Video.FileName);
            var videoFileName = $"{Guid.NewGuid()}{videoExt}";
            var videoPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "memories", videoFileName);
            Directory.CreateDirectory(Path.GetDirectoryName(videoPath)!);
            using (var stream = new FileStream(videoPath, FileMode.Create))
            {
                await request.Video.CopyToAsync(stream);
            }
            videoUrl = $"/uploads/memories/{videoFileName}";
        }
        
        var entry = new MemoryEntry { CoupleId = couple.Id, Text = request.Text, PhotoUrl = photoUrl, VideoUrl = videoUrl, IsPinned = request.IsPinned };
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

    public async Task<ActionResult> GetQuestionToday(int userId)
    {
        var couple = await GetCouple(userId);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var q = await db.DailyQuestions.FirstOrDefaultAsync(x => x.Day == today);
        if (q is null)
        {
            q = new DailyQuestion { Day = today, Category = "romantic", Text = "Какое воспоминание о нас ты хранишь особенно бережно?" };
            db.DailyQuestions.Add(q);
            await db.SaveChangesAsync();
        }
        if (couple is null)
            return new OkObjectResult(new { q.Id, q.Text, q.Category, myAnswer = (string?)null, partnerAnswer = (string?)null });

        var answers = await db.DailyQuestionAnswers
            .Where(x => x.QuestionId == q.Id && x.CoupleId == couple.Id)
            .ToListAsync();
        var myAnswer = answers.FirstOrDefault(x => x.UserId == userId)?.Answer;
        var partnerAnswer = myAnswer != null ? answers.FirstOrDefault(x => x.UserId != userId)?.Answer : null;
        return new OkObjectResult(new { q.Id, q.Text, q.Category, myAnswer, partnerAnswer });
    }

    public Task<ActionResult> GetQuestionWithAnswers(int userId) => GetQuestionToday(userId);

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
        logger.LogInformation("=== AddLovePoint START === UserId: {UserId}", userId);
        logger.LogInformation("Photo null: {PhotoNull}, Video null: {VideoNull}", request.Photo == null, request.Video == null);
        
        var couple = await GetCouple(userId);
        if (couple is null) 
        {
            logger.LogWarning("No couple for user {UserId}", userId);
            return new BadRequestObjectResult(new { message = "No couple connected" });
        }
        
        string? photoUrl = null;
        string? videoUrl = null;
        
        // Save photo if provided
        if (request.Photo != null)
        {
            logger.LogInformation("Photo received: {Name}, {Length} bytes", request.Photo.FileName, request.Photo.Length);
            var photoExt = Path.GetExtension(request.Photo.FileName);
            var photoFileName = $"{Guid.NewGuid()}{photoExt}";
            var photoPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "lovemap", photoFileName);
            logger.LogInformation("Saving to: {Path}", photoPath);
            Directory.CreateDirectory(Path.GetDirectoryName(photoPath)!);
            using (var stream = new FileStream(photoPath, FileMode.Create))
            {
                await request.Photo.CopyToAsync(stream);
            }
            var fileInfo = new FileInfo(photoPath);
            logger.LogInformation("Saved: Exists={Exists}, Size={Size}", fileInfo.Exists, fileInfo.Length);
            photoUrl = $"/uploads/lovemap/{photoFileName}";
        }
        else
        {
            logger.LogWarning("Photo is NULL in service!");
        }
        
        // Save video if provided
        if (request.Video != null)
        {
            var videoExt = Path.GetExtension(request.Video.FileName);
            var videoFileName = $"{Guid.NewGuid()}{videoExt}";
            var videoPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "lovemap", videoFileName);
            Directory.CreateDirectory(Path.GetDirectoryName(videoPath)!);
            using (var stream = new FileStream(videoPath, FileMode.Create))
            {
                await request.Video.CopyToAsync(stream);
            }
            videoUrl = $"/uploads/lovemap/{videoFileName}";
        }
        
        var point = new LoveMapPoint { 
            CoupleId = couple.Id, 
            Latitude = request.Latitude, 
            Longitude = request.Longitude, 
            PhotoUrl = photoUrl, 
            VideoUrl = videoUrl,
            Description = request.Description,
            Address = request.Address 
        };
        db.LoveMapPoints.Add(point);
        await db.SaveChangesAsync();
        logger.LogInformation("=== AddLovePoint SUCCESS === PointId: {PointId}, PhotoUrl: {PhotoUrl}", point.Id, point.PhotoUrl);
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
        var records = await db.FinanceRecords.Where(x => x.CoupleId == couple.Id).OrderByDescending(x => x.DateUtc).ToListAsync();
        var income = records.Where(x => x.Type == "income").Sum(x => x.Amount);
        var expense = records.Where(x => x.Type == "expense").Sum(x => x.Amount);
        var goals = await db.FinanceGoals.Where(x => x.CoupleId == couple.Id).ToListAsync();
        return new OkObjectResult(new
        {
            totalIncome = income,
            totalExpense = expense,
            balance = income - expense,
            recentRecords = records.Take(10),
            goals
        });
    }

    public async Task<ActionResult> GetActiveChallenge(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new OkObjectResult((object?)null);
        var challenge = await db.CoupleChallenges.FirstOrDefaultAsync(x => x.CoupleId == couple.Id && !x.IsCompleted);
        if (challenge is null) return new OkObjectResult((object?)null);
        var template = await db.ChallengeTemplates.FindAsync(challenge.TemplateId);
        var completedDays = await db.ChallengeProgresses
            .Where(x => x.CoupleChallengeId == challenge.Id && x.Done)
            .Select(x => x.Day.ToString("yyyy-MM-dd"))
            .ToListAsync();
        return new OkObjectResult(new
        {
            challenge.Id,
            challenge.TemplateId,
            title = template?.Title ?? "",
            durationDays = template?.DurationDays ?? 7,
            startedOn = challenge.StartedOn.ToString("yyyy-MM-dd"),
            completedDays,
            challenge.IsCompleted
        });
    }

    public async Task<ActionResult> GetAllSecretMessages(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        var messages = await db.SecretMessages
            .Where(x => x.CoupleId == couple.Id)
            .OrderByDescending(x => x.OpenAtUtc)
            .ToListAsync();
        return new OkObjectResult(messages.Select(m => new
        {
            m.Id,
            m.Message,
            m.OpenAtUtc,
            isOpened = m.OpenAtUtc <= DateTime.UtcNow,
            isMine = m.SenderUserId == userId
        }));
    }

    public async Task<ActionResult> GetCheckinStatus(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new OkObjectResult(new { mySubmitted = false, partnerSubmitted = false });
        var now = DateTime.UtcNow.Date;
        var monday = DateOnly.FromDateTime(now.AddDays(-((int)now.DayOfWeek + 6) % 7));
        var checkins = await db.WeeklyCheckIns
            .Where(x => x.CoupleId == couple.Id && x.WeekStart == monday)
            .Select(x => x.UserId)
            .ToListAsync();
        return new OkObjectResult(new
        {
            mySubmitted = checkins.Contains(userId),
            partnerSubmitted = checkins.Any(x => x != userId),
            weekStart = monday.ToString("yyyy-MM-dd")
        });
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
        // Индексы вопросов (0-based):
        // Надёжный (secure): 0,2,4,6,9,12,14,16,18,20,23
        // Тревожный (anxious): 1,3,7,11,15,21
        // Избегающий (avoidant): 5,8,10,13,17,19,22,24

        var answers = request.Answers;
        if (answers == null || answers.Count != 25)
            return new BadRequestObjectResult(new { message = "Требуется 25 ответов" });

        int SecureScore() => answers[0] + answers[2] + answers[4] + answers[6] + answers[9]
                           + answers[12] + answers[14] + answers[16] + answers[18] + answers[20] + answers[23];

        int AnxiousScore() => answers[1] + answers[3] + answers[7] + answers[11] + answers[15] + answers[21];

        int AvoidantScore() => answers[5] + answers[8] + answers[10] + answers[13] + answers[17] + answers[19] + answers[22] + answers[24];

        var secure = SecureScore();
        var anxious = AnxiousScore();
        var avoidant = AvoidantScore();

        string type = (secure, anxious, avoidant) switch
        {
            var t when t.secure >= t.anxious && t.secure >= t.avoidant => "secure",
            var t when t.anxious >= t.secure && t.anxious >= t.avoidant => "anxious",
            _ => "avoidant"
        };

        var recommendation = type switch
        {
            "secure" => "Вы обладаете надёжным типом привязанности. Продолжайте практиковать регулярные эмоциональные чекины и совместные ритуалы. Ваша способность доверять и открываться — отличный фундамент для здоровых отношений. Обсуждайте с партнёром свои чувства, чтобы сохранять близость.",
            "anxious" => "У вас тревожный тип привязанности. Работайте над ритуалами утешения и спокойной реакцией в конфликтах. Постарайтесь обсуждать свои страхи с партнёром, а не накапливать их. Регулярные заверения в любви и предсказуемое поведение помогут вам чувствовать себя в безопасности.",
            _ => "У вас избегающий тип привязанности. Практикуйте эмоциональную открытость и предсказуемое общение. Постепенно учитесь делиться чувствами с партнёром — это укрепит связь. Уважайте свою потребность в личном пространстве, но помните, что близость требует уязвимости."
        };

        var result = new AttachmentTestResult
        {
            UserId = userId,
            AttachmentType = type,
            Recommendation = recommendation
        };
        db.AttachmentTestResults.Add(result);
        await db.SaveChangesAsync();
        return new OkObjectResult(result);
    }

    public async Task<ActionResult> GetAttachmentTestResult(int userId)
    {
        var couple = await GetCouple(userId);
        if (couple is null) return new BadRequestObjectResult(new { message = "No couple connected" });
        
        // Get user's result
        var userResult = await db.AttachmentTestResults
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .FirstOrDefaultAsync();
        
        // Get partner's result
        var partnerId = couple.User1Id == userId ? couple.User2Id : couple.User1Id;
        var partnerResult = partnerId.HasValue 
            ? await db.AttachmentTestResults
                .Where(x => x.UserId == partnerId.Value)
                .OrderByDescending(x => x.CreatedAtUtc)
                .FirstOrDefaultAsync()
            : null;
        
        if (userResult is null && partnerResult is null) 
            return new NotFoundObjectResult(new { message = "Результаты теста не найдены" });
        
        return new OkObjectResult(new {
            user = userResult != null ? new { 
                attachmentType = userResult.AttachmentType,
                recommendation = userResult.Recommendation 
            } : null,
            partner = partnerResult != null ? new { 
                attachmentType = partnerResult.AttachmentType,
                recommendation = partnerResult.Recommendation 
            } : null
        });
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
