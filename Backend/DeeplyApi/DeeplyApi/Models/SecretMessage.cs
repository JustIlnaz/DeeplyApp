using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class SecretMessage
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    public int SenderUserId { get; set; }
    [MaxLength(3000)] public string Message { get; set; } = string.Empty;
    public DateTime OpenAtUtc { get; set; }
}
