using DeeplyApi.Models;
using Microsoft.EntityFrameworkCore;

namespace DeeplyApi.Connection;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Couple> Couples => Set<Couple>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<ChatMessage> ChatMessages => Set<ChatMessage>();
    public DbSet<MemoryEntry> MemoryEntries => Set<MemoryEntry>();
    public DbSet<CoupleEvent> CoupleEvents => Set<CoupleEvent>();
    public DbSet<MoodEntry> MoodEntries => Set<MoodEntry>();
    public DbSet<DailyQuestion> DailyQuestions => Set<DailyQuestion>();
    public DbSet<DailyQuestionAnswer> DailyQuestionAnswers => Set<DailyQuestionAnswer>();
    public DbSet<WeeklyCheckIn> WeeklyCheckIns => Set<WeeklyCheckIn>();
    public DbSet<ChallengeTemplate> ChallengeTemplates => Set<ChallengeTemplate>();
    public DbSet<CoupleChallenge> CoupleChallenges => Set<CoupleChallenge>();
    public DbSet<ChallengeProgress> ChallengeProgresses => Set<ChallengeProgress>();
    public DbSet<TimeCapsule> TimeCapsules => Set<TimeCapsule>();
    public DbSet<SecretMessage> SecretMessages => Set<SecretMessage>();
    public DbSet<LoveMapPoint> LoveMapPoints => Set<LoveMapPoint>();
    public DbSet<CoupleTodo> CoupleTodos => Set<CoupleTodo>();
    public DbSet<FinanceRecord> FinanceRecords => Set<FinanceRecord>();
    public DbSet<FinanceGoal> FinanceGoals => Set<FinanceGoal>();
    public DbSet<AttachmentTestResult> AttachmentTestResults => Set<AttachmentTestResult>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Couple>()
            .HasOne(x => x.User1)
            .WithMany()
            .HasForeignKey(x => x.User1Id)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Couple>()
            .HasOne(x => x.User2)
            .WithMany()
            .HasForeignKey(x => x.User2Id)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<User>().HasIndex(x => x.Email).IsUnique();
        modelBuilder.Entity<Couple>().HasIndex(x => x.InviteCode).IsUnique();
        modelBuilder.Entity<MoodEntry>().HasIndex(x => new { x.UserId, x.Day }).IsUnique();
        modelBuilder.Entity<DailyQuestion>().HasIndex(x => x.Day).IsUnique();
        modelBuilder.Entity<DailyQuestionAnswer>().HasIndex(x => new { x.QuestionId, x.UserId }).IsUnique();
        modelBuilder.Entity<ChallengeProgress>().HasIndex(x => new { x.CoupleChallengeId, x.Day }).IsUnique();
    }
}
