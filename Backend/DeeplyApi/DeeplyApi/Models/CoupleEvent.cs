using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class CoupleEvent
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    [MaxLength(200)] public string Title { get; set; } = string.Empty;
    [MaxLength(1000)] public string? Description { get; set; }
    public DateTime StartsAtUtc { get; set; }
    public DateTime? EndsAtUtc { get; set; }
    public DateTime? ReminderAtUtc { get; set; }
}
