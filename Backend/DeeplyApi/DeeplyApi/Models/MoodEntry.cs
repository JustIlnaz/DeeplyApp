using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class MoodEntry
{
    [Key] public int Id { get; set; }
    public int UserId { get; set; }
    public int CoupleId { get; set; }
    [MaxLength(100)] public string MoodType { get; set; } = "neutral";
    [MaxLength(500)] public string? Comment { get; set; }
    public DateOnly Day { get; set; }
}
