using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class DailyQuestion
{
    [Key] public int Id { get; set; }
    [MaxLength(20)] public string Category { get; set; } = "light";
    [MaxLength(1000)] public string Text { get; set; } = string.Empty;
    public DateOnly Day { get; set; }
}
