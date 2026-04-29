using DeeplyApi.Models;
using Microsoft.EntityFrameworkCore;

namespace DeeplyApi.Connection
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Couple> Couples { get; set; }
        public DbSet<Gendre> Gendres { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
        public DbSet<ChatMessage> ChatMessages { get; set; }
        public DbSet<MemoryEntry> MemoryEntries { get; set; }
        public DbSet<CoupleEvent> CoupleEvents { get; set; }
        public DbSet<MoodEntry> MoodEntries { get; set; }
        public DbSet<DailyQuestion> DailyQuestions { get; set; }
        public DbSet<DailyQuestionAnswer> DailyQuestionAnswers { get; set; }
        public DbSet<WeeklyCheckIn> WeeklyCheckIns { get; set; }
        public DbSet<ChallengeTemplate> ChallengeTemplates { get; set; }
        public DbSet<CoupleChallenge> CoupleChallenges { get; set; }
        public DbSet<ChallengeProgress> ChallengeProgresses { get; set; }
        public DbSet<TimeCapsule> TimeCapsules { get; set; }
        public DbSet<SecretMessage> SecretMessages { get; set; }
        public DbSet<LoveMapPoint> LoveMapPoints { get; set; }
        public DbSet<CoupleTodo> CoupleTodos { get; set; }
        public DbSet<FinanceRecord> FinanceRecords { get; set; }
        public DbSet<FinanceGoal> FinanceGoals { get; set; }
        public DbSet<AttachmentTestResult> AttachmentTestResults { get; set; }

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

        modelBuilder.Entity<User>()
            .HasOne(x => x.Gendre)
            .WithMany(x => x.Users)
            .HasForeignKey(x => x.GendreId)
            .OnDelete(DeleteBehavior.SetNull);

        modelBuilder.Entity<Gendre>().HasIndex(x => x.Name).IsUnique();
        modelBuilder.Entity<User>().HasIndex(x => x.Email).IsUnique();
        modelBuilder.Entity<Couple>().HasIndex(x => x.InviteCode).IsUnique();
        modelBuilder.Entity<MoodEntry>().HasIndex(x => new { x.UserId, x.Day }).IsUnique();
        modelBuilder.Entity<DailyQuestion>().HasIndex(x => x.Day).IsUnique();
        modelBuilder.Entity<DailyQuestionAnswer>().HasIndex(x => new { x.QuestionId, x.UserId }).IsUnique();
        modelBuilder.Entity<ChallengeProgress>().HasIndex(x => new { x.CoupleChallengeId, x.Day }).IsUnique();
    }
}
}