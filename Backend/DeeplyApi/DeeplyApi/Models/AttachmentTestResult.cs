using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class AttachmentTestResult
{
    [Key] public int Id { get; set; }
    public int UserId { get; set; }
    [MaxLength(30)] public string AttachmentType { get; set; } = "secure";
    [MaxLength(2000)] public string Recommendation { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
