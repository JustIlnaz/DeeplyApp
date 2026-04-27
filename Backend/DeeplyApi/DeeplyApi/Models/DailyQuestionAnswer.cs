using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class DailyQuestionAnswer
{
    [Key] public int Id { get; set; }
    public int QuestionId { get; set; }
    public int UserId { get; set; }
    public int CoupleId { get; set; }
    [MaxLength(2000)] public string Answer { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
