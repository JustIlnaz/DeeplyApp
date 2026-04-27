using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class MemoryEntry
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    [MaxLength(1000)] public string? Text { get; set; }
    [MaxLength(500)] public string? PhotoUrl { get; set; }
    [MaxLength(500)] public string? VideoUrl { get; set; }
    public bool IsPinned { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
