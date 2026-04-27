using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class ChatMessage
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    public int SenderUserId { get; set; }
    [MaxLength(4000)] public string? Text { get; set; }
    [MaxLength(500)] public string? PhotoUrl { get; set; }
    public bool IsRead { get; set; }
    public DateTime SentAtUtc { get; set; } = DateTime.UtcNow;
}
